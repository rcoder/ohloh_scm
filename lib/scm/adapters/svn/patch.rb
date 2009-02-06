module Scm::Adapters
  class SvnAdapter < AbstractAdapter
    def patch_for_commit(commit)
      parent = commit.token.to_i - 1
      run("svn diff -r#{parent}:#{commit.token} #{url}")
    end
  end
end
