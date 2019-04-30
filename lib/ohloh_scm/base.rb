# frozen_string_literal: true

using OhlohScm::StringExtensions

module OhlohScm
  class Base
    attr_reader :scm, :activity, :status

    def initialize(scm_type, url, branch_name, username, password)
      scm_opts = { base: self, url: url, branch_name: branch_name,
                   username: username, password: password }
      @scm = OhlohScm.const_get("#{scm_type.to_s.camelize}Scm").new(scm_opts)
      @activity = OhlohScm.const_get("#{scm_type.to_s.camelize}Activity").new(self)
      @status = OhlohScm.const_get("#{scm_type.to_s.camelize}Status").new(self)
    end
  end
end
