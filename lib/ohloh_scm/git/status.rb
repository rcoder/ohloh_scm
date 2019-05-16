# frozen_string_literal: true

module OhlohScm
  module Git
    class Status < OhlohScm::Status
      def branch?(name = scm.branch_name)
        return unless scm_dir_exist?

        activity.branches.include?(name)
      end
    end
  end
end
