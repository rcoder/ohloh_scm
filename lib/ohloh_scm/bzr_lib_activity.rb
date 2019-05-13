# frozen_string_literal: true

require_relative 'py_bridge/py_client'
require_relative 'py_bridge/bzr_lib_client'

module OhlohScm
  class BzrLibActivity < BzrActivity
    def cat(revision, path)
      bzr_client.cat_file(revision, path)
    end

    def cleanup
      bzr_client.shutdown
    end

    private

    def parent_tokens(commit)
      bzr_client.parent_tokens(commit.token)
    end

    def bzr_client
      @bzr_client ||= setup_bzr_client
    end

    def setup_bzr_client
      bzr_client = BzrLibClient.new(url)
      bzr_client.start
      bzr_client
    end
  end
end
