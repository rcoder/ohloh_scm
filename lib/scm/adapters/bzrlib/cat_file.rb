module Scm::Adapters
	class BzrlibAdapter < BzrAdapter

		def cat(revision, path)
      content = bzr_commander.get_file_content(path, to_rev_param(revision, false))
      # When file is not present in a revision, get_file_content returns None python object.
      # None cannot be used as nil, hence must be compared to nil and converted.
      if content != nil
        content.to_s
      else
        nil
      end
		end

	end
end
