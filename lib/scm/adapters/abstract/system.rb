module Scm::Adapters
	require 'logger'
	class AbstractAdapter
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
			status, out, err = systemu(cmd)
			raise RuntimeError.new("#{cmd} failed: #{out}\n#{err}") if status.exitstatus != 0
			out
		end

		def run(cmd)
			AbstractAdapter::run(cmd)
		end

		# As above, but does not raise an exception when an error occurs.
		# Returns two values, stdout and stderr.
		def self.run_with_err(cmd)
			logger.debug { cmd }
			status, out, err = systemu(cmd)
			[out, err]
		end

		def run_with_err(cmd)
			AbstractAdapter::run_with_err(cmd)
		end
	end
end
