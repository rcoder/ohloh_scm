module Scm::Adapters
	class HgAdapter < AbstractAdapter

		def push(to, &block)
			raise ArgumentError.new("Cannot push to #{to.inspect}") unless to.is_a?(HgAdapter)
			logger.info { "Pushing to #{to.url}" }

			yield(0,1) if block_given? # Progress bar callback

			unless to.exist?
				if to.local?
					# Create a new repo on the same local machine. Just use existing pull code in reverse.
					to.pull(self)
				else
					run "ssh #{to.hostname} 'mkdir -p #{to.path}'"
					run "scp -rpqB #{hg_path} #{to.hostname}:#{to.path}"
				end
			else
				run "cd '#{self.url}' && hg push -f -y '#{to.url}'"
			end

			yield(1,1) if block_given? # Progress bar callback
		end

		def local?
			return true if hostname == Socket.gethostname
			return false if url =~ /:/
			true
		end

		def hostname
			url =~ /^([^:^\/]+):(.+)/ ? $1 : nil
		end

		def path
			url =~ /^([^:^\/]+):(.+)/ ? $2 : nil
		end
	end
end
