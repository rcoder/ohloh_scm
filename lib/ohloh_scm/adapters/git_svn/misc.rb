module OhlohScm::Adapters
  class GitSvnAdapter < AbstractAdapter
    def git_svn_log(cmd:, oneline:)
      oneline_flag = '--oneline' if oneline
      run("#{git_svn_log_cmd} #{oneline_flag} #{cmd}").strip
    end

    def accept_ssl_certificate_cmd
      File.expand_path('../../../../../bin/accept_svn_ssl_certificate', __FILE__)
    end

    def username_and_password_opts(source_scm)
      username = source_scm.username.to_s.empty? ? '' : "--username #{ @source_scm.username }"
      password = source_scm.password.to_s.empty? ? '' : "--password='#{@source_scm.password}'"
      "#{username} #{password}"
    end

    private

    def git_svn_log_cmd
      "cd #{self.url} && git svn log"
    end
  end
end
