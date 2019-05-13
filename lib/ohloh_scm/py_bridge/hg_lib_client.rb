# frozen_string_literal: true

module OhlohScm
  class HgLibClient < PyClient
    def initialize(repository_url)
      @repository_url = repository_url
      @py_script = "#{__dir__}/hg_lib_server.py"
    end

    def cat_file(revision, file)
      send_command("CAT_FILE\t#{revision}\t#{file}")
    rescue RuntimeError => e
      raise unless e.message =~ /not found in manifest/ # File does not exist.
    end

    def parent_tokens(revision)
      send_command("PARENT_TOKENS\t#{revision}").split("\t")
    end

    private

    def open_repository
      send_command("REPO_OPEN\t#{@repository_url}")
    end
  end
end
