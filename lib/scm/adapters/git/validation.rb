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
      @url = read_only_url
			@branch_name = 'master' if @branch_name.to_s == ''
			self
		end

    # Given a Github read-write URL, return a read-only URL.
    # Otherwise, return the original URL.
    def read_only_url
      case @url
      when /^https:\/\/\w+@github.com\/(.+)\.git$/
        "git://github.com/#{$1}.git"
      when /^git@github.com:(.+)\.git$/
        "git://github.com/#{$1}.git"
      else
        @url
      end
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
