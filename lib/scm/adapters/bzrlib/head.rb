module Scm::Adapters
	class BzrlibAdapter < BzrAdapter

		def parent_tokens(commit)
      bzr_client.parent_tokens(to_rev_param(commit.token, false))
		end

	end
end
