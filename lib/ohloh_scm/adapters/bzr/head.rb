module OhlohScm::Adapters
	class BzrAdapter < AbstractAdapter
		def head_token
			run("bzr log --limit 1 --show-id #{url} 2> /dev/null | grep ^revision-id | cut -f2 -d' '").strip
		end

		def head
			verbose_commit(head_token)
		end

		def parent_tokens(commit)
			run("cd '#{url}' && bzr log --long --show-id --limit 1 -c #{to_rev_param(commit.token)} | grep ^parent | cut -f2 -d' '").split("\n")
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end
	end
end
