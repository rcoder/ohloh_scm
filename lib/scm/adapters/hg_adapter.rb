module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def english_name
			"Mercurial"
		end
	end
end

require 'lib/scm/adapters/hg/validation'
require 'lib/scm/adapters/hg/cat_file'
require 'lib/scm/adapters/hg/misc'
