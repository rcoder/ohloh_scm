module Scm::Adapters
	class GitAdapter < AbstractAdapter
		def self.url_regex
			/^(http|https|rsync|git|ssh):\/\/(\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/[A-Za-z0-9_\-\.\/\~\+]*$/
		end

		def self.public_url_regex
			/^(http|https|git):\/\/(\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/[A-Za-z0-9_\-\.\/\~\+]*$/
		end

		def normalize
			super
			@branch_name = 'master' if @branch_name.to_s == ''
			self
		end

		def validate_server_connection
			return unless valid?
			@errors << [:failed, "The server did not respond to the 'git-ls-remote' command. Is the URL correct?"] unless self.exists?
		end

		def guess_forge
			u = @url =~ /:\/\/(.*\.?git\.)?([^\/^:]+)(:\d+)?\// ? $2 : nil
			case u
			when /(sourceforge\.net$)/
				$1
			else
				u
			end
		end
	end
end
