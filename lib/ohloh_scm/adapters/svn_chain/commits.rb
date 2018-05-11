module OhlohScm::Adapters
	class SvnChainAdapter < SvnAdapter

		# Returns the count of commits following revision number 'after'.
		def commit_count(opts={})
			(parent_svn(opts[:after]) ? parent_svn(opts[:after]).commit_count(opts) : 0) + super(opts)
		end

		# Returns an array of revision numbers for all commits following revision number 'after'.
		def commit_tokens(opts={})
			(parent_svn(opts[:after]) ? parent_svn(opts[:after]).commit_tokens(opts) : []) + super(opts)
		end

		# Returns an array of commits following revision number 'after'.
		def commits(opts={})
			(parent_svn(opts[:after]) ? parent_svn(opts[:after]).commits(opts) : []) + super(opts)
		end

		def verbose_commit(rev=0)
			parent_svn(rev) ? parent_svn.verbose_commit(rev) : super(rev)
		end

		# If the diff points to a file, simply returns the diff.
		# If the diff points to a directory, returns an array of diffs for every file in the directory.
		def deepen_diff(diff, rev)
      if %w(A R).include?(diff.action) && diff.path == '' && parent_svn && rev == first_token
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
