# frozen_string_literal: true

require_relative 'py_bridge/hg_lib_client'

module OhlohScm
  class HgLibActivity < HgActivity
    def cat_file(commit, diff)
      hg_client.cat_file(commit.token, diff.path)
    end

    def cat_file_parent(commit, diff)
      tokens = parent_tokens(commit)
      hg_client.cat_file(tokens.first, diff.path) if tokens.first
    end

    def cleanup
      hg_client.shutdown
    end

    private

    def parent_tokens(commit)
      hg_client.parent_tokens(commit.token)
    end

    def hg_client
      @hg_client ||= setup_hg_client
    end

    def setup_hg_client
      hg_client = HgLibClient.new(url)
      hg_client.start
      hg_client
    end
  end
end
