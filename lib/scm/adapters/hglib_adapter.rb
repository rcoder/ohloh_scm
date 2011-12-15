require 'rubygems'
require 'lib/scm/adapters/hglib/client'

module Scm::Adapters
	class HglibAdapter < HgAdapter

    def setup
      hg_client = HglibClient.new(url)
      hg_client.start
      hg_client
    end

    def hg_client
      @hg_client ||= setup
    end

    def cleanup
      @hg_client && @hg_client.shutdown
    end

	end
end

require 'lib/scm/adapters/hglib/cat_file'
require 'lib/scm/adapters/hglib/head'
