# frozen_string_literal: true

module OhlohScm
  class BzrLibClient < PyClient
    def initialize(repository_url)
      @repository_url = repository_url
      @py_script = "#{__dir__}/bzr_lib_server.py"
    end

    def cat_file(revision, file)
      send_command("CAT_FILE|#{revision}|#{file}")
    end

    def parent_tokens(revision)
      send_command("PARENT_TOKENS|#{revision}").split('|')
    end

    private

    def open_repository
      send_command("REPO_OPEN|#{@repository_url}")
    end
  end
end
