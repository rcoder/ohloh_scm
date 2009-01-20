module Scm::Adapters
	class HgAdapter < AbstractAdapter
		def self.url_regex
			/^(http|https):\/\/(\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/[A-Za-z0-9_\-\.\/\~\+]*$/
		end

		def self.public_url_regex
			/^(http|https):\/\/(\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/[A-Za-z0-9_\-\.\/\~\+]*$/
		end

#		def validate_server_connection
#			return unless valid?
#			@errors << [:failed, "The server did not respond to the 'git-ls-remote' command. Is the URL correct?"] unless self.exists?
#		end
	end
end
