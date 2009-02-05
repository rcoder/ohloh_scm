module Scm::Adapters
	class SvnAdapter < AbstractAdapter

		def first_revision(since=0)
			commit_tokens(since).first
		end

		def first_commit(since=0)
			verbose_commit(first_revision)
		end
	
		def parent_svn(since=0)
			c = first_commit(since)
			if c && c.diffs.size == 1
				d = c.diffs.first
				if d.action == 'A' && d.path == branch_name && d.from_path && d.from_revision
					prior_svn = self.clone
					prior_svn.branch_name = d.from_path
					prior_svn.final_revision = d.from_revision
					prior_svn
				end
			end
		end

	end
end
