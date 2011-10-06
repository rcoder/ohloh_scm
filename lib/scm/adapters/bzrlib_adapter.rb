require 'rubygems'
require 'rubypython'

module Scm::Adapters
	class BzrlibAdapter < BzrAdapter 
		def english_name
			"Bazaar"
		end
    def setup
      ENV['PYTHONPATH'] = File.dirname(__FILE__) + '/bzrlib'
      RubyPython.start
      @bzrlib = RubyPython.import('bzrlib_commands')
      @commander = @bzrlib.BzrCommander.new(url)
    end
    def bzr_commander
      setup unless @commander
      return @commander
    end
    def cleaup
      bzr_commander.cleanup
      RubyPython.stop
    end
	end
end

require 'lib/scm/adapters/bzrlib/head'
require 'lib/scm/adapters/bzrlib/cat_file'
