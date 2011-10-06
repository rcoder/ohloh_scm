module Scm::Adapters
	class BzrlibAdapter < BzrAdapter
		def cat_file(commit, diff)
			cat(commit.token, diff.path)
		end

    def cat_file_parent(commit, diff)
      first_parent_token = parent_tokens(commit).first
      cat(first_parent_token, diff.path) if first_parent_token
    end

		def cat(revision, path)
      begin
        content = bzr_commander.get_file_content(path, to_rev_param(revision, false)) 
        # When file is not present in a revision, get_file_content returns None python object.
        # None cannot be used as nil, hence must be compared to nil and converted. 
        if content != nil
          out = content.to_s
        else
          out = nil
        end
      rescue => expt
        raise RuntimeError.new(expt.message)
      end
			out
		end

		# Bzr doesn't like it when the filename includes a colon
		# Also, fix the case where the filename includes a single quote
		def escape(path)
			path.gsub(/[:]/) { |c| '\\' + c }.gsub("'", "''")
		end
	end
end
