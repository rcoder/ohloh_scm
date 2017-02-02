module OhlohScm::Adapters
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

require_relative 'cvs/validation'
require_relative 'cvs/commits'
require_relative 'cvs/misc'
