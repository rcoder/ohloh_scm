module OhlohScm::Adapters
	class SvnAdapter < AbstractAdapter
		def english_name
			"Subversion"
		end
	end
end

require_relative 'svn/validation'
require_relative 'svn/cat_file'
require_relative 'svn/commits'
require_relative 'svn/push'
require_relative 'svn/pull'
require_relative 'svn/head'
require_relative 'svn/misc'
require_relative 'svn/patch'

