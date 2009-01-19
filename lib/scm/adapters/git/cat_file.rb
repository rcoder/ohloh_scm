module Scm::Adapters
	class GitAdapter < AbstractAdapter
		def cat_file(commit, diff)
			cat(diff.sha1)
		end

		def cat_file_parent(commit, diff)
			cat(diff.parent_sha1)
		end

		def cat(sha1)
			run "cd '#{url}' && git cat-file -p #{sha1}"
		end
	end
end
