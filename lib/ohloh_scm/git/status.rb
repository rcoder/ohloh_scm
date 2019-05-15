# frozen_string_literal: true

module OhlohScm
  module Git
    class Status < OhlohScm::Status
      def validate_server_connection
        return unless valid?

        msg = "The server did not respond to the 'git-ls-remote' command. Is the URL correct?"
        @errors << [:failed, msg] unless exist?
      end

      def public_url_regex
        %r{^(http|https|git)://(\w+@)?[\w\-\.]+(:\d+)?/[\w\-\./\~\+]*$}
      end

      def branch?(name = scm.branch_name)
        return unless scm_dir_exist?

        activity.branches.include?(name)
      end
    end
  end
end
