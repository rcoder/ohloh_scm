require 'socket'

module OhlohScm::Adapters
	class GitAdapter < AbstractAdapter

		COMMITTER_NAME = 'ohloh_slave' unless defined?(COMMITTER_NAME)

		def push(to)
			logger.info { "Pushing to #{to.url}" }

			if to.exist?
				ENV['GIT_COMMITTER_NAME'] = COMMITTER_NAME
				run "cd '#{self.url}' && git push '#{to.url}' #{self.branch_name}:#{to.branch_name}"
			else
				if to.local?
					# Create a new repo on the same local machine. Just use existing pull code in reverse.
					to.pull(self)
				else
					run "ssh #{to.hostname} 'mkdir -p #{to.path}'"
					run "scp -rpqB #{git_path} #{to.hostname}:#{to.path}"
				end
			end
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
