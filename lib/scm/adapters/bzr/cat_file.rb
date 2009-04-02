module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def cat_file(commit, diff)
			cat(commit.token, diff.path)
		end

		def cat_file_parent(commit, diff)
			p = parents(commit)
			cat(p.first.token, diff.path) if p.first
		end

		def cat(revision, path)
			out, err, status = run_with_err("cd '#{url}' && bzr cat --name-from-revision -r #{to_rev_param(revision)} '#{escape(path)}'")
			return nil if err =~ / is not present in revision /
			raise RuntimeError.new(err) unless status == 0
			out
		end

		# Bzr doesn't like it when the filename includes a colon
		# Also, fix the case where the filename includes a single quote
		def escape(path)
			path.gsub(/[:]/) { |c| '\\' + c }.gsub("'", "''")
		end
	end
end
