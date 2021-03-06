module Scm::Adapters
	class BzrAdapter < AbstractAdapter
		def self.url_regex
			/^((http|https|bzr\+ssh|file):\/\/((\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/)?)?[A-Za-z0-9_\-\.\/\~\+]*$/
		end

		def self.public_url_regex
			/^(http|https):\/\/(\w+@)?[A-Za-z0-9_\-\.]+(:\d+)?\/[A-Za-z0-9_\-\.\/\~\+]*$/
		end

		def validate_server_connection
			return unless valid?
			@errors << [:failed, "The server did not respond to the 'bzr revno' command. Is the URL correct?"] unless self.exist?
		end
	end
end
