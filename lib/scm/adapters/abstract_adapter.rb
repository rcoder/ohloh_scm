module Scm::Adapters
	class AbstractAdapter
		attr_accessor :url, :branch_name, :username, :password, :errors, :public_urls_only

		def initialize(params={})
			@url = params[:url]
			@branch_name = params[:branch_name]
			@username = params[:username]
			@password = params[:password]
			@public_urls_only = params[:public_urls_only]
		end

		# Handy for test overrides
		def metaclass
			class << self
				self
			end
		end

	end
end

require 'lib/scm/adapters/abstract/system'
require 'lib/scm/adapters/abstract/validation'
require 'lib/scm/adapters/abstract/sha1'
require 'lib/scm/adapters/abstract/misc'
