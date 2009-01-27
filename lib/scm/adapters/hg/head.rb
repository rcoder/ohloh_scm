module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def head_token
			# This only returns first 12 characters.
			# How can we make it return the entire hash?
			run("hg id -q #{url}").strip
		end

		def head
			verbose_commit(head_token)
		end

		def parent_tokens(commit)
			run("cd '#{url}' && hg parents -r #{commit.token} --template '{node}\\n'").split("\n")
		end

		def parents(commit)
			parent_tokens(commit).collect { |token| verbose_commit(token) }
		end
	end
end
