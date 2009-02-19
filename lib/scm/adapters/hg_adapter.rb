module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def english_name
			"Mercurial"
		end
	end
end

require 'lib/scm/adapters/hg/validation'
require 'lib/scm/adapters/hg/cat_file'
require 'lib/scm/adapters/hg/commits'
require 'lib/scm/adapters/hg/misc'
require 'lib/scm/adapters/hg/pull'
require 'lib/scm/adapters/hg/push'
require 'lib/scm/adapters/hg/head'
require 'lib/scm/adapters/hg/patch'
