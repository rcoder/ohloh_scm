module OhlohScm::Adapters
	class AbstractAdapter
		# The full regex that permits all possible URLs supported by the source control system.
		def self.url_regex
			/.+/
		end

		# A limited regex that permits only URLs that are publicly addressable on the web.
		# This regex should refuse access to local disk files.
		def self.public_url_regex
			/.+/
		end

		def validate
			@errors = []
			@errors << validate_url
			@errors << validate_branch_name
			@errors << validate_username
			@errors << validate_password
			@errors.compact!
		end

		def validate_url
			return [:url, "The URL can't be blank."] unless @url and @url.length > 0
			return [:url, "The URL must not be longer than 120 characters."] unless @url.length <= 120

			regex = @public_urls_only ? self.class.public_url_regex : self.class.url_regex
			return [:url, "The URL does not appear to be a valid server connection string."] unless @url =~ regex
		end

		def validate_branch_name
			return nil if @branch_name.to_s == ''
			return [:branch_name, "The branch name must not be longer than 80 characters."] unless @branch_name.length <= 80
			return [:branch_name, "The branch name may contain only letters, numbers, spaces, and the special characters '_', '-', '+', '/', '^', and '.'"] unless @branch_name =~ /^[A-Za-z0-9_^\-\+\.\/\ ]+$/
		end

		def validate_username
			return nil unless @username
			return [:username, "The username must not be longer than 32 characters."] unless @username.length <= 32
			return [:username, "The username may contain only A-Z, a-z, 0-9, and underscore (_)"] unless @username =~ /^\w*$/
		end

		def validate_password
			return nil unless @password
			return [:password, "The password must not be longer than 32 characters."] unless @password.length <= 32
			return [:password, "The password contains illegal characters"] unless @password =~ /^[\w!@\#$%^&*\(\)\{\}\[\]\;\?\|\+\-\=]*$/
		end

		def valid?
			validate
			errors.empty?
		end

		def exists?
			exist?
		end

		# Ping the remote server to ensure it is responding and that the desired branch exists.
		def validate_server_connection
		end

		# Give the object a chance to massage/cleanup its input attributes
		def normalize
			@url.strip! if @url
			@branch_name.strip! if @branch_name
			@username.strip! if @username
			@password.strip! if @password
			self
		end

		# Based on the URL, return the domain name of the forge hosting this code.
		def guess_forge
			# This is a very general rule for systems using HTTP-style URLs.
			url =~ /:\/\/([^\/]+)\// ? $1 : nil
		end
	end
end
