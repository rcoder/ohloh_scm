module OhlohScm::Adapters
	class SvnAdapter < AbstractAdapter

		def push(to)
			logger.warn { "Pushing #{to.url}" }

			unless to.exist?
				to.svnadmin_create
				to.svnsync_init(self)
			end
			SvnAdapter.svnsync_sync(self, to)
		end

	end
end
