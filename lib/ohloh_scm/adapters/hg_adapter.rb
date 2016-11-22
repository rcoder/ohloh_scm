module OhlohScm::Adapters
	class HgAdapter < AbstractAdapter
		def english_name
			"Mercurial"
		end
	end
end

require_relative 'hg/validation'
require_relative 'hg/cat_file'
require_relative 'hg/commits'
require_relative 'hg/misc'
require_relative 'hg/pull'
require_relative 'hg/push'
require_relative 'hg/head'
require_relative 'hg/patch'
