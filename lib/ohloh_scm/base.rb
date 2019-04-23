# frozen_string_literal: true

module OhlohScm
  class Base
    include OhlohScm::System
    attr_reader :scm, :activity, :status

    def initialize(scm_type, url, branch_name)
      @scm = OhlohScm.const_get("#{scm_type.capitalize}Scm").new(base: self, url: url,
                                                                 branch_name: branch_name)
      @activity = OhlohScm.const_get("#{scm_type.capitalize}Activity").new(self)
      @status = OhlohScm.const_get("#{scm_type.capitalize}Status").new(self)
    end
  end
end
