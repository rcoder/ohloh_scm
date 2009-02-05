module Scm::Adapters
	class AbstractAdapter
		attr_accessor :url, :branch_name, :username, :password, :errors, :public_urls_only

		def initialize(params={})
			params.each { |k,v| send(k.to_s + '=', v) if respond_to?(k.to_s + '=') }
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
