# frozen_string_literal: true

module OhlohScm
  module Factory
    module_function

    def get_base(scm_type: :git, url:, branch_name: nil)
      OhlohScm::Base.new(scm_type, url, branch_name)
    end
  end
end
