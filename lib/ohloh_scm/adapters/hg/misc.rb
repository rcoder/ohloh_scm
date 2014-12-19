module OhlohScm::Adapters
	class HgAdapter < AbstractAdapter
		def exist?
			begin
				!!(head_token)
			rescue
				logger.debug { $! }
				false
			end
		end

		def ls_tree(token)
			run("cd '#{path}' && hg manifest -r #{token} | #{ string_encoder }").split("\n")
		end

		def export(dest_dir, token='tip')
			run("cd '#{path}' && hg archive -r #{token} '#{dest_dir}'")
			# Hg leaves a little cookie crumb in the export directory. Remove it.
			File.delete(File.join(dest_dir, '.hg_archival.txt')) if File.exist?(File.join(dest_dir, '.hg_archival.txt'))
		end
	end
end
