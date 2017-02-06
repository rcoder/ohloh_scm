module OhlohScm::Adapters
	class BzrAdapter < AbstractAdapter

		def push(to, &block)
			raise ArgumentError.new("Cannot push to #{to.inspect}") unless to.is_a?(BzrAdapter)
			logger.info { "Pushing to #{to.url}" }

			yield(0,1) if block_given? # Progress bar callback

			unless to.exist?
				if to.local?
					# Create a new repo on the same local machine. Just use existing pull code in reverse.
					to.pull(self)
				else
					run "ssh #{to.hostname} 'mkdir -p #{to.path}'"
					run "scp -rpqB #{bzr_path} #{to.hostname}:#{to.path}"
				end
			else
				run "cd '#{self.url}' && bzr revert && bzr push '#{to.url}'"
			end

			yield(1,1) if block_given? # Progress bar callback
		end

		def local?
			return true if hostname == Socket.gethostname
			return true if url =~ /^file:\/\//
			return true if url !~ /:/
			false
		end

		def hostname
			$1 if url =~ /^bzr\+ssh:\/\/([^\/]+)/
		end

		def path
			case url
			when /^file:\/\/(.+)$/
				$1
			when /^bzr\+ssh:\/\/[^\/]+(\/.+)$/
				$1
			when /^[^:]*$/
				url
			end
		end

		def bzr_path
			path && File.join(path, '.bzr')
		end
	end
end
