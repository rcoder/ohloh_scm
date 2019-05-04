# frozen_string_literal: true

module OhlohScm
  class GitStatus < Status
    def validate_server_connection
      return unless valid?

      msg = "The server did not respond to the 'git-ls-remote' command. Is the URL correct?"
      @errors << [:failed, msg] unless exists?
    end

    def public_url_regex
      %r{^(http|https|git)://(\w+@)?[\w\-\.]+(:\d+)?/[\w\-\./\~\+]*$}
    end

    def git_dir_exist?
      Dir.exist?("#{scm.url}/.git")
    end

    def branch?(name = scm.branch_name)
      return unless git_dir_exist?

      activity.branches.include?(name)
    end

    def exist?
      return unless git_dir_exist?

      !activity.head_token.to_s.empty?
    end
  end
end
