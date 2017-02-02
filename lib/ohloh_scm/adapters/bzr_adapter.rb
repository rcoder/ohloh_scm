module OhlohScm::Adapters
	class BzrAdapter < AbstractAdapter
		def english_name
			"Bazaar"
		end
	end
end

require_relative 'bzr/validation'
require_relative 'bzr/commits'
require_relative 'bzr/head'
require_relative 'bzr/cat_file'
require_relative 'bzr/misc'
require_relative 'bzr/pull'
require_relative 'bzr/push'
