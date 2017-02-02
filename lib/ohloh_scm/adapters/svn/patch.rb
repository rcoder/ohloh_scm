module OhlohScm::Adapters
  class SvnAdapter < AbstractAdapter
    def patch_for_commit(commit)
      parent = commit.token.to_i - 1
      run("svn diff --trust-server-cert --non-interactive -r#{parent}:#{commit.token} #{url}")
    end
  end
end
