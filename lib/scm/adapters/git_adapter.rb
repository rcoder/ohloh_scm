module Scm::Adapters
	class GitAdapter < AbstractAdapter
		def english_name
			"Git"
		end
	end
end

require 'lib/scm/adapters/git/validation'
require 'lib/scm/adapters/git/cat_file'
require 'lib/scm/adapters/git/commits'
require 'lib/scm/adapters/git/commit_all'
require 'lib/scm/adapters/git/token'
require 'lib/scm/adapters/git/push'
require 'lib/scm/adapters/git/pull'
require 'lib/scm/adapters/git/head'
require 'lib/scm/adapters/git/misc'
