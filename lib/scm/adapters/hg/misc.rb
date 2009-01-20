module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def exist?
			begin
				!!(tip_token)
			rescue
				logger.debug { $! }
				false
			end
		end

		def tip_token
			run("hg id -q #{url}").strip
		end

		def tip_commit
			Scm::Parsers::HgParser.parse(run("cd '#{url}' && hg tip")).first
		end

		def parent_commit(commit)
			Scm::Parsers::HgParser.parse(run("cd '#{url}' && hg parents -r #{commit.token}")).first
		end
	end
end
