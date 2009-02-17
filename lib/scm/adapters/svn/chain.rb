module Scm::Adapters
	class SvnAdapter < AbstractAdapter

		# Some explanation is in order about "chaining."
		#
		# First, realize that a base SvnAdapter only tracks the history of a single
		# subdirectory. If you point an adapter at /trunk, then that adapter is
		# going to ignore eveything in /branches and /tags.
		#
		# The problem with this is that directories often get moved about.  What is
		# called "/trunk" today might have been in a branch directory at some point
		# in the past. But since we completely ignore other directories, we never see
		# that old history.
		#
		# Suppose for example that from revisions 1 to 100, development occured in
		# /branches/beta. Then at revision 101, /trunk was created by copying
		# /branches/beta, and this /trunk lives on to this day.
		#
		# The log for revision 101 is going to look something like this:
		#
		# Changed paths:
		#    D /branches/beta
		#    A /trunk (from /branches/beta:100)
		#
		# A single SvnAdapter pointed at today's /trunk will only see revisions 101
		# through HEAD, because /trunk didn't even exist before revision 101.
		#
		# To capture the prior history, we need to create *another* SvnAdapter
		# which points at /branches/beta, and which considers revisions from 1 to 100.
		#
		# That's what chaining is: when we find that the first commit of an adapter
		# indicates the wholesale renaming or copying of the entire tree from
		# another location, then we generate a new SvnAdapter that points to that
		# prior location, and process that SvnAdapter as well.
		#
		# This behavior recurses ("chains") all the way back to revision 1.
		#
		# It only works if the *entire branch* moves. We don't chain when
		# subdirectories or individual files are copied.

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
				 c.diffs.each do |d|
					 if (b = parent_branch_name(d))
						 parent = SvnAdapter.new(:url => File.join(root, b), :branch_name => b,
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
			Scm::Parsers::SvnXmlParser.parse(next_revision_xml(since)).first
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
