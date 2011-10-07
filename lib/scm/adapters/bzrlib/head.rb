module Scm::Adapters
	class BzrlibAdapter < BzrAdapter

		def parent_tokens(commit)
      bzr_commander.get_parent_tokens(to_rev_param(commit.token, false)).to_enum
		end

	end
end
