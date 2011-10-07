module Scm::Adapters
	class BzrlibAdapter < BzrAdapter

		def cat(revision, path)
      content = bzr_client.cat_file(to_rev_param(revision, false), path)
      # When file is not present in a revision, get_file_content returns None python object.
      # None cannot be used as nil, hence must be compared to nil and converted.
      return content
		end

	end
end
