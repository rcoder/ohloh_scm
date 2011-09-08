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
      pwd = Dir.pwd
      begin
        out = bzrlib_commands.bzr_cat(self.url, path, to_rev_param(revision, false)).to_s
      rescue => expt
			  # return nil if err =~ / is not present in revision /
        if expt.message =~ / is not present in revision /
          out = nil
        else
          raise RuntimeError.new(expt.message)
        end
      ensure
        Dir.chdir(pwd)
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
