module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def english_name
			"Bazaar"
		end
	end
end

require 'lib/scm/adapters/bzr/validation'
