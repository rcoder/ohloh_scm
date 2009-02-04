module Scm::Adapters
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

		# This method returns the list of commits you must fetch if you are
		# current as of old_head, and wish to be current up to new_head.
		def walk(old_head=nil, new_head=head_token)
			if old_head
				run("cd #{url} && git rev-list --reverse #{old_head.to_s}..#{new_head.to_s}").split("\n")
			else
				run("cd #{url} && git rev-list --reverse #{new_head.to_s}").split("\n")
			end
		end
	end
end
