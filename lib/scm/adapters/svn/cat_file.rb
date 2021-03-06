module Scm::Adapters
	class SvnAdapter < AbstractAdapter
		def cat_file(commit, diff)
			cat(diff.path, commit.token)
		end

		def cat_file_parent(commit, diff)
			cat(diff.path, commit.token.to_i-1)
		end

		def cat(path=nil, revision='HEAD')
			begin
				run "svn cat -r #{revision} '#{SvnAdapter.uri_encode(File.join(self.root, self.branch_name.to_s, path.to_s))}@#{revision}'"
			rescue
				raise unless $!.message =~ /svn: (File not found|.* is not a directory in filesystem)/
			end
		end
	end
end
