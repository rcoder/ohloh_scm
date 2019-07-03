module OhlohScm::Adapters
	class HgAdapter < AbstractAdapter

		def pull(from, &block)
			raise ArgumentError.new("Cannot pull from #{from.inspect}") unless from.is_a?(HgAdapter)
			logger.info { "Pulling #{from.url}" }

			yield(0,1) if block_given? # Progress bar callback

			unless self.exist?
				run "mkdir -p '#{self.url}'"
				run "rm -rf '#{self.url}'"
				run "hg clone '#{from.url}' '#{self.url}'"
			else
        branch_opts = "-r #{ from.branch_name }" if branch_name
				run "cd '#{self.url}' && hg revert --all && hg pull #{ branch_opts } -u -y '#{from.url}'"
			end

      clean_up_disk
			yield(1,1) if block_given? # Progress bar callback
		end

    private

    def clean_up_disk
      return unless FileTest.exist?(url)
      run "cd #{url} && find . -maxdepth 1 -not -name .hg -not -name . -print0 | xargs -0 rm -rf --"
    end
	end
end
