module OhlohScm::Adapters
	class GitAdapter < AbstractAdapter

		def head_token
			run("git ls-remote --heads '#{url}' #{branch_name}") =~ /^(^[a-z0-9]{40})\s+\S+$/
			$1
		end

		def head
			verbose_commit(head_token)
		end

		def parent_tokens(commit)
			run("cd '#{url}' && git cat-file commit #{commit.token} | grep ^parent | cut -f 2 -d ' '").split("\n") || []
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end
	end
end
