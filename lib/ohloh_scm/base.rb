# frozen_string_literal: true

module OhlohScm
  class Base
    include OhlohScm::System
    attr_reader :scm, :activity, :status

    def initialize(scm_type, url, branch_name, username, password)
      scm_opts = { base: self, url: url, branch_name: branch_name,
                   username: username, password: password }
      @scm = OhlohScm.const_get("#{scm_type.capitalize}Scm").new(scm_opts)
      @activity = OhlohScm.const_get("#{scm_type.capitalize}Activity").new(self)
      @status = OhlohScm.const_get("#{scm_type.capitalize}Status").new(self)
    end

    def logger
      System.logger
    end
  end
end
