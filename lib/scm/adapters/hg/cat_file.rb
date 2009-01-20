module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def cat_file(commit, diff)
			cat(commit.token, diff.path)
		end

		def cat_parent_file(commit, diff)
			cat(parent_commit(commit).token, diff.path)
		end

		def cat(revision, path)
			out, err = run_with_err("cd '#{url}' && hg cat -r #{revision} '#{path}'")
			return nil if err =~ /No such file in rev/
			raise RuntimeError.new(err) unless err.to_s == ''
			out
		end
	end
end
