module OhlohScm::Adapters
  class HglibAdapter < HgAdapter

    def parent_tokens(commit)
      hg_client.parent_tokens(commit.token)
    end

  end
end
