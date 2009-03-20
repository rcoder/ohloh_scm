module Scm::Adapters
	class SvnChainAdapter < SvnAdapter

		# Returns the entire SvnAdapter ancestry chain as a simple array.
		def chain
			(parent_svn ? parent_svn.chain : []) << self
		end

		# If this adapter's branch was created by copying or renaming another branch,
		# then return a new adapter that points to that prior branch.
		#
		# Only commits following +since+ are considered, so if the copy or rename
		# occured on or before +since+, then no parent will be found or returned.
		def parent_svn(since=0)
			@parent_svn ||={} # Poor man's memoize

			@parent_svn[since] ||= begin
				parent = nil
				c = first_commit(since)
				if c
					# === Long explanation of real head-scratching bug fix. ===
					#
					# It is possible for some Subversion commits to include *multiple*
					# renames/copies of a source directory. For example:
					#
					#    A /foo (from /trunk:1)
					#    D /foo/my_branch
					#    A /foo/bar (from /trunk:1)
					#    D /trunk
					#
					# If we simply processed these entries in the order given, then
					# we would conclude that /foo/bar/my_branch has parent
					# /trunk/bar/my_branch (because the first A matches) and exit.
					#
					# This is incorrect! We must look for the *longest* A that matches
					# our path, and follow that one. In the example above, the correct
					# parent for /foo/bar/my_branch is /trunk/my_branch.
					#
					# Therefore, we must sort diffs by descending filename length, so
					# that we choose the longest match.
					c.diffs.sort { |a,b| b.path.length <=> a.path.length }.each do |d|
						if (b = parent_branch_name(d))
							parent = SvnChainAdapter.new(
								:url => File.join(root, b), :branch_name => b,
								:username => username, :password => password,
								:final_token => d.from_revision).normalize
								break
						end
					end
				end
				parent
			end
		end

		def first_token(since=0)
			c = first_commit(since)
			c && c.token
		end

		def first_commit(since=0)
			@first_commit ||={} # Poor man's memoize
			@first_commit[since] ||= Scm::Parsers::SvnXmlParser.parse(next_revision_xml(since)).first
		end

		# Returns the first commit with a revision number greater than the provided revision number
		def next_revision_xml(since=0)
			return "<?xml?>" if since.to_i >= head_token
			run "svn log --verbose --xml --stop-on-copy -r #{since.to_i+1}:#{final_token || 'HEAD'} --limit 1 #{opt_auth} '#{SvnAdapter.uri_encode(File.join(self.root, self.branch_name))}@#{final_token || 'HEAD'}'"
		end

		# If the passed diff represents the wholesale movement of the entire
		# code tree from one directory to another, this method returns the name
		# of the previous directory.
		def parent_branch_name(d)
			if d.action == 'A' && branch_name[0, d.path.size] == d.path && d.from_path && d.from_revision
				d.from_path + branch_name[d.path.size..-1]
			end
		end
	end
end
