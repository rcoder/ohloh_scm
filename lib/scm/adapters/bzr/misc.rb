module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def exist?
			begin
				!!(head_token)
			rescue
				logger.debug { $! }
				false
			end
		end

		def ls_tree(token)
			run("cd #{path} && bzr ls -V -r #{token}").split("\n")
		end
	end
end
