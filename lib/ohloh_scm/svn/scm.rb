# frozen_string_literal: true

module OhlohScm
  module Svn
    class Scm < OhlohScm::Scm
      def normalize
        url = prefix_file_for_local_path(@url)
        @url = force_https_if_sourceforge(url)
        if branch_name
          clean_branch_name
        else
          @branch_name = recalc_branch_name
        end
        self
      end

      # From the given URL, determine which part of it is the root and
      # which part of it is the branch_name. The current branch_name is overwritten.
      def recalc_branch_name
        @branch_name = url ? url[activity.root.length..-1] : branch_name
      rescue RuntimeError => e
        pattern = /(svn:*is not a working copy|Unable to open an ra_local session to URL)/
        @branch_name = '' if e.message =~ pattern # we have a file system
      ensure
        clean_branch_name
        branch_name
      end

      def accept_ssl_certificate_cmd
        File.expand_path('../../../.bin/accept_svn_ssl_certificate', __dir__)
      end

      private

      def clean_branch_name
        return unless branch_name

        @branch_name.chop! if branch_name.to_s.end_with?('/')
      end

      def force_https_if_sourceforge(url)
        return url unless url =~ /http(:\/\/.*svn\.(sourceforge|code\.sf)\.net.*)/

        # SourceForge requires https for svnsync
        "https#{Regexp.last_match(1)}"
      end

      # If the URL is a simple directory path, make sure it is prefixed by file://
      def prefix_file_for_local_path(path)
        return if path.empty?

        %r{://}.match?(url) ? url : 'file://' + File.expand_path(path)
      end
    end
  end
end
