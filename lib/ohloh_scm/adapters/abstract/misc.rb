module OhlohScm::Adapters
	class AbstractAdapter

		def is_merge_commit?(commit)
			false
		end

	end
end
