module OhlohScm::Adapters
  class HgAdapter < AbstractAdapter
    def patch_for_commit(commit)
      parent_tokens(commit).map {|token|
        run("hg -R '#{url}' diff --git -r#{token} -r#{commit.token}")
      }.join("\n")
    end
  end
end
