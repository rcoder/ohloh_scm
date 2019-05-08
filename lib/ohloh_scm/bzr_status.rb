# frozen_string_literal: true

module OhlohScm
  class BzrStatus < Status
    def validate_server_connection
      return unless valid?

      msg = "The server did not respond to the 'bzr revno' command. Is the URL correct?"
      @errors << [:failed, msg] unless exist?
    end

    def public_url_regex
      %r{^(((http|https|bzr)://(\w+@)?[\w\-\.]+(:\d+)?/)|(lp:[\w\-\.\~]))[\w\-\./\~\+]*$}
    end
  end
end
