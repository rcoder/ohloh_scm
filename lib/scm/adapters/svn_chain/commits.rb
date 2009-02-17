module Scm::Adapters
	class SvnChainAdapter < SvnAdapter

		# Returns the count of commits following revision number 'since'.
		def commit_count(since=0)
			(parent_svn ? parent_svn.commit_count(since) : 0) + super(since)
		end

		# Returns an array of revision numbers for all commits following revision number 'since'.
		def commit_tokens(since=0)
			(parent_svn(since) ? parent_svn.commit_tokens(since) : []) + super(since)
		end

		# Returns an array of commits following revision number 'since'.
		def commits(since=0)
			(parent_svn(since) ? parent_svn.commits(since) : []) + super(since)
		end

		def verbose_commit(since=0)
			parent_svn(since) ? parent_svn.verbose_commit(since) : super(since)
		end

		# If the diff points to a file, simply returns the diff.
		# If the diff points to a directory, returns an array of diffs for every file in the directory.
		def deepen_diff(diff, rev)
			if diff.action == 'A' && diff.path == '' && parent_svn && rev == first_token
				# A very special case that is important for chaining.
				# This is the first commit, and the entire tree is being created by copying from parent_svn.
				# In this case, there isn't actually any change, just
				# a change of branch_name. Return no diffs at all.
				nil
			else
				super(diff, rev)
			end
		end
	end
end
