module OhlohScm::Adapters
	require 'logger'
	class AbstractAdapter
    include POSIX::Spawn

		def self.logger
			@@logger ||= Logger.new(STDERR)
		end

		def self.logger=(val)
			@@logger = val
		end

		def logger
			self.class.logger
		end

		# Custom implementation of shell execution, does not block when the "pipe is full."
		# Raises an exception if the shell returns non-zero exit code.
		def self.run(cmd)
			logger.debug { cmd }
			status, out, err = Shellout.execute(cmd)
			raise RuntimeError.new("#{cmd} failed: #{out}\n#{err}") if status.exitstatus != 0
			out
		end

		def run(cmd)
			AbstractAdapter::run(cmd)
		end

    def popen(cmd, filename)
      logger.debug { cmd }
      file = File.open(filename, 'w')
      pid, input, out, err = popen4(cmd)
      while true
        Timeout.timeout(60 * 15) do
          buffer = out.readpartial(50000)
          file.write(buffer)
        end
      end
    rescue EOFError
    ensure
      file.close
      pid, status = Process::waitpid(pid) if pid
      raise RuntimeError.new("#{cmd} failed: #{out}\n#{err}") if status && status.exitstatus != 0
    end

		# As above, but does not raise an exception when an error occurs.
		# Returns three values: stdout, stderr, and process exit code
		def self.run_with_err(cmd)
			logger.debug { cmd }
			status, out, err = Shellout.new.run(cmd)
			[out, err, status]
		end

		def run_with_err(cmd)
			AbstractAdapter::run_with_err(cmd)
		end
	end
end
