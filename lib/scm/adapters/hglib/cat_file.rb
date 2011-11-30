module Scm::Adapters
	class HglibAdapter < HgAdapter

		def cat(revision, path)
      hg_client.cat_file(revision, path)
		end

	end
end
