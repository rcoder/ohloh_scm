# frozen_string_literal: true

module OhlohScm
  module Bzr
    class Scm < OhlohScm::Scm
      def pull(from)
        if status.exist?
          run "cd '#{url}' && bzr revert && bzr pull --overwrite '#{from.url}'"
        else
          run "rm -rf '#{url}'"
          run "bzr branch '#{from.url}' '#{url}'"
        end
      end

      def vcs_path
        "#{url}/.bzr"
      end
    end
  end
end
