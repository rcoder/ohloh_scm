module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def head_token
			run("bzr revno -q #{url}").strip
		end

		def head
			verbose_commit(head_token)
		end

		def parent_tokens(commit)
			run("cd '#{url}' && bzr log -c $((#{commit.token} - 1)) --log-format=line | cut -f1 -d':'").split("\n")
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end
	end
end
