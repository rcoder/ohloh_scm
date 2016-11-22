module OhlohScm::Adapters
	class HglibAdapter < HgAdapter

		def cat_file(commit, diff)
      hg_client.cat_file(commit.token, diff.path)
		end

    def cat_file_parent(commit, diff)
      tokens = parent_tokens(commit)
      hg_client.cat_file(tokens.first, diff.path) if tokens.first
    end

	end
end
