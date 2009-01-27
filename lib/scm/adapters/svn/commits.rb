require 'rexml/document'

module Scm::Adapters
	class SvnAdapter < AbstractAdapter

		# In all commit- and log-related methods, 'since' refers to the revision number of the last known commit,
		# and the methods return the commits *following* this commit.
		#
		# Examples:
		#    commits(1) => [rev 2, rev 3, ..., HEAD]
		#    commits(3) => [rev 4, rev 5, ..., HEAD]
		#
		# This is convenient for Ohloh -- Ohloh passes the last commit it is aware of, and these methods return any new commits.

		# Returns the count of commits following revision number 'since'.
		def commit_count(since=0)
			run("svn log -q -r #{since.to_i + 1}:HEAD --stop-on-copy '#{SvnAdapter.uri_encode(File.join(root, branch_name.to_s))}' | grep -E -e '^r[0-9]+ ' | wc -l").strip.to_i
		end

		# Returns an array of revision numbers for all commits following revision number 'since'.
		def commit_tokens(since=0)
			cmd = "svn log -q -r #{since.to_i + 1}:HEAD --stop-on-copy '#{SvnAdapter.uri_encode(File.join(root, branch_name.to_s))}' | grep -E -e '^r[0-9]+ ' | cut -f 1 -d '|' | cut -c 2-"
			run(cmd).split.collect { |r| r.to_i }
		end

		# Returns an array of commits following revision number 'since'. These commit objects do not include diffs.
		def commits(since=0)
			c = []
			open_log_file(since) do |io|
				c = Scm::Parsers::SvnXmlParser.parse(io)
			end

			# We may be using a log saved on disk from a previous fetch.
			# If so, exclude the portion of the log up to 'since'.
			c.each_index do |i|
				if c[i].token.to_i == since.to_i
					if i == commits.size-1
						# We're up to date
						return []
					else
						return c[i+1..-1]
					end
				end
			end
			c
		end

		# Yields each commit following revision number 'since'. These commit object are populated with diffs.
		#
		# With Subversion, populating the diffs can be tricky because when an entire directory is affected,
		# Subversion abbreviates the log by simply listing the directory name, rather than all of the directory
		# contents. Since Ohloh requires the list of every individual file affected, and doesn't care about
		# directories, the complexity (and time) of this method comes in expanding directories with a recursion
		# through every file in the directory.
		#
		def each_commit(since=nil)
			commit_tokens(since).each do |rev|
				yield deepen_commit(strip_commit_branch(verbose_commit(rev)))
			end
		end

		# For a given commit, replace any diffs that point to directories with diffs for each file that
		# the directory contains.
		def deepen_commit(commit)
			deep_commit = commit.clone
			if commit.diffs
				deep_commit.diffs = commit.diffs.collect do |diff|
					deepen_diff(diff, commit.token)
				end.flatten.uniq.sort { |a,b| a.action <=> b.action }.sort { |a,b| a.path <=> b.path }
			end

			remove_dupes(deep_commit)
		end

		def remove_dupes(commit)
			# Strange case correction.
			#
			# Subversion may report that a directory is added, and then also that a file within that directory is modified.
			# Because we expand directories, the result is that the file may be listed twice -- once as part of our expansion,
			# and once from the regular log entry.
			#
			# So look for diffs of the form ["M", "path"] which are matched by ["A", "path"] and remove them.
			if commit.diffs
				commit.diffs.delete_if do |d|
					d.action =~ /[MR]/ && commit.diffs.select { |x| x.action == 'A' and x.path == d.path }.any?
				end
			end
			commit
		end

		# If the diff points to a file, simply returns the diff.
		# If the diff points to a directory, returns an array of diffs for every file in the directory.
		def deepen_diff(diff, rev)
			# Note that if the directory was deleted, we have to look at the previous revision to see what it held.
			recurse_rev = (diff.action == 'D') ? rev-1 : rev
			if (diff.action == 'D' or diff.action == 'A') && is_directory?(diff.path, recurse_rev)
				recurse_files(diff.path, recurse_rev).collect do |f|
					Scm::Diff.new(:action => diff.action, :path => File.join(diff.path, f))
				end
			else
				diff
			end
		end

		# Strip all paths in this commit to remove the leading branch_name.
		# Throw away any diffs in the commit that don't lie in the branch_name we care about.
		def strip_commit_branch(commit)
			stripped_commit = commit.clone
			if commit.diffs
				stripped_commit.diffs = commit.diffs.collect { |d| strip_diff_branch(d) }.compact
			end
			stripped_commit
		end

		# Return a new diff whose path excludes the leading branch_name.
		# If the diff is not in the branch, return nil.
		def strip_diff_branch(diff)
			stripped_diff = diff.clone
			stripped_diff.path = strip_path_branch(diff.path)
			stripped_diff.path && stripped_diff
		end

		# Returns only the portion of the path following branch_name.
		# Returns nil if the path is not within the branch.
		def strip_path_branch(path)
			if path == self.branch_name.to_s
				''
			else
				$1 if path =~ /^#{Regexp.escape(self.branch_name.to_s)}(\/.*)$/
			end
		end

		# A single commit, including any changed paths.
		# Basically equivalent to the data you get back from the Subversion log when you pass the --verbose flag.
		def verbose_commit(rev)
			Scm::Parsers::SvnXmlParser.parse(single_revision_xml(rev)).first
		end

		#---------------------------------------------------------------------
		# Log-related code ; get log for entire file or single revision
		#---------------------------------------------------------------------

		def log(since=0)
			run "svn log --xml --stop-on-copy -r #{since.to_i + 1}:HEAD '#{SvnAdapter.uri_encode(self.url)}' #{opt_auth}"
		end

		def open_log_file(since=0)
			begin
				if (since.to_i + 1) <= head_token
					run "svn log --xml --stop-on-copy -r #{since.to_i + 1}:HEAD '#{SvnAdapter.uri_encode(self.url)}' #{opt_auth} > #{log_filename}"
				else
					# As a time optimization, just create an empty file rather than fetch a log we know will be empty.
					File.open(log_filename, 'w') { |f| f.puts '<?xml version="1.0"?>' }
				end
				File.open(log_filename, 'r') { |io| yield io }
			ensure
				File.delete(log_filename) if FileTest.exist?(log_filename)
			end
		end

		def log_filename
		  File.join('/tmp', (self.url).gsub(/\W/,'') + '.log')
		end

		def single_revision_xml(revision)
			run "svn log --verbose --xml --stop-on-copy -r #{revision} --limit 1 #{opt_auth} '#{SvnAdapter.uri_encode(self.url)}@#{revision}'"
		end

		# Recurses the entire repository and returns an array of file names.
		# Directories are not returned.
		# Directories named 'CVSROOT' are always ignored and the files they contain are never returned.
		# An empty array means that the call succeeded, but the remote directory is empty.
		# A nil result means that the call failed and the remote server could not be queried.
		def recurse_files(path=nil, revision='HEAD')
			begin
				stdout = run "svn ls -r #{revision} --recursive #{opt_auth} '#{SvnAdapter.uri_encode(File.join(root, branch_name.to_s, path.to_s))}@#{revision}'"
			rescue
				puts $!.inspect
				return nil
			end

			files = []
			stdout.each_line do |s|
				s.chomp!
				files << s if s.length > 0 and s !~ /CVSROOT\// and s[-1..-1] != '/'
			end
			files.sort
		end
	end
end
