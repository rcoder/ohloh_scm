module Scm::Adapters
	class CvsAdapter < AbstractAdapter
		attr_accessor :module_name

		def english_name
			'CVS'
		end

		def initialize(params={})
			super
			@module_name = params[:module_name]
		end
	end
end

require 'lib/scm/adapters/cvs/validation'
require 'lib/scm/adapters/cvs/commits'
require 'lib/scm/adapters/cvs/misc'
