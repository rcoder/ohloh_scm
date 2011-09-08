require 'rubygems'
require 'rubypython'

module Scm::Adapters
	class BzrlibAdapter < BzrAdapter 
		def english_name
			"Bazaar"
		end
    def bzrlib_commands
      @bzrlib_commands ||= begin
        ENV['PYTHONPATH'] = File.dirname(__FILE__) + '/bzrlib'
        RubyPython.start
        RubyPython.import('bzrlib_commands')
      end
    end
    def cleaup
      RubyPython.stop
    end
	end
end

require 'lib/scm/adapters/bzrlib/head'
require 'lib/scm/adapters/bzrlib/cat_file'
