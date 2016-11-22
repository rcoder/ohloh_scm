module OhlohScm::Adapters
  class GitAdapter < AbstractAdapter
    def patch_for_commit(commit)
      parent_tokens(commit).map {|token|
        run("cd #{url} && git diff #{token} #{commit.token}")
      }.join("\n")
    end
  end
end
