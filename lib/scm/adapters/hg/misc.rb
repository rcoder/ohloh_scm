module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def exist?
			begin
				!!(head_token)
			rescue
				logger.debug { $! }
				false
			end
		end

		def ls_tree(token)
			run("cd #{path} && hg manifest -r #{token}").split("\n")
		end
	end
end
