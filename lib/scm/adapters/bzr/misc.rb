module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def exist?
			begin
				head_token.to_s.length > 0
			rescue
				logger.debug { $! }
				false
			end
		end

		def ls_tree(token)
			run("cd #{path} && bzr ls -V -r #{to_rev_param(token)}").split("\n")
		end

		# If you want to pass a revision-id as a bzr parameter, you
		# must prefix it with "revid:". This takes care of that.
		def to_rev_param(r=nil)
			case r
			when nil
				1
			when Fixnum
				r.to_s
			when /^\d+$/
				r
			else
				"'revid:#{r.to_s}'"
			end
		end

		def is_merge_commit?(commit)
			parent_tokens(commit).size > 1
		end
	end
end
