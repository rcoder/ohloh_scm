require 'rubygems'

require_relative 'bzrlib/bzrlib_pipe_client'
module OhlohScm::Adapters
	class BzrlibAdapter < BzrAdapter

    def setup
      @bzr_client = BzrPipeClient.new(url)
      @bzr_client.start
    end

    def bzr_client
      setup unless @bzr_client
      return @bzr_client
    end

    def cleanup
      @bzr_client.shutdown
    end

	end
end

require_relative 'bzrlib/head'
require_relative 'bzrlib/cat_file'
