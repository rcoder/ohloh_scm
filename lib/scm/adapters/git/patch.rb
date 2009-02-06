module Scm::Adapters
  class GitAdapter < AbstractAdapter
    def patch_for_commit(commit)
      parents_tokens(commit).map {|token|
        run("cd #{url} && git diff #{commit.token} #{token}")
      }.join("\n")
    end
  end
end
