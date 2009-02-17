module Scm::Adapters
	class SvnAdapter < AbstractAdapter
		def english_name
			"Subversion"
		end
	end
end

require 'lib/scm/adapters/svn/validation'
require 'lib/scm/adapters/svn/cat_file'
require 'lib/scm/adapters/svn/commits'
require 'lib/scm/adapters/svn/push'
require 'lib/scm/adapters/svn/pull'
require 'lib/scm/adapters/svn/head'
require 'lib/scm/adapters/svn/misc'
