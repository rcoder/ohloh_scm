module OhlohScm::Adapters
	class GitAdapter < AbstractAdapter

		#---------------------------------------------------------------------------
		# TOKEN-RELATED CODE
		#
		# As CVS and Subversion are converted to Git, the unique ID of each commit
		# from the original source control system is stored in a special token file.
		#
		# Whenever Ohloh needs to incrementally update our local copy of the code with
		# the latest commits, we just check the token file to see at which point we need
		# to restart the process.
		#---------------------------------------------------------------------------

		def token_filename
			'ohloh_token'
		end

		def token_path
			File.join(self.url, token_filename)
		end

		# Determine the most recent revision that was safely stored in the GIT archive.
		# Resets the token file on disk to the most recent version stored in the repository.
		def read_token
			token = nil
			if self.exist?
				begin
					token = run("cd '#{url}' && git cat-file -p `git ls-tree HEAD #{token_filename} | cut -c 13-51`").strip
				rescue RuntimeError => e
					# If the git repository doesn't have a token file yet, it will error out.
					# We want to just quietly return nil.
					if e.message =~ /pathspec '#{token_filename}' did not match any file\(s\) known to git/
						return nil
					else
						raise
					end
				end
			end
			token
		end

		# Saves the new token in a well-known file.
		# If the passed token is empty, this method silently does nothing.
		def write_token(token)
			if token and token.to_s.length > 0
				File.open(token_path, 'w') do |f|
					f.write token.to_s
				end
			end
		end
	end
end
