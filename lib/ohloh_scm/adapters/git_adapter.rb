module OhlohScm::Adapters
	class GitAdapter < AbstractAdapter
		def english_name
			"Git"
		end
	end
end

require_relative 'git/validation'
require_relative 'git/cat_file'
require_relative 'git/commits'
require_relative 'git/commit_all'
require_relative 'git/token'
require_relative 'git/push'
require_relative 'git/pull'
require_relative 'git/head'
require_relative 'git/misc'
require_relative 'git/patch'
