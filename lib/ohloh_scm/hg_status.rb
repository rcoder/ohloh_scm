# frozen_string_literal: true

module OhlohScm
  class HgStatus < Status
    def validate_server_connection
      return unless valid?

      msg = "The server did not respond to the 'hg id' command. Is the URL correct?"
      @errors << [:failed, msg] unless exist?
    end

    def public_url_regex
      %r{^(http|https)://(\w+@)?[\w\-\.]+(:\d+)?/[\w\-\./\~\+]*$}
    end
  end
end
