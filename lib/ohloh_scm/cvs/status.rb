# frozen_string_literal: true

module OhlohScm
  module Cvs
    class Status < OhlohScm::Status
      def lock?
        run "timeout 2m cvsnt -q -d #{scm.url} rlog '#{scm.branch_name}'"
        false
      rescue StandardError => e
        raise 'CVS lock has been found' if e.message =~ /waiting for.*lock in/
      end
    end
  end
end
