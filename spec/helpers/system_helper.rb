# We intend to keep System functions protected.
class SystemPrivateAccessor
  extend OhlohScm::System

  class << self
    def run_private(cmd)
      run(cmd)
    end

    def run_with_error_private(cmd)
      run_with_err(cmd)
    end
  end
end

module SystemHelper
  # Cannot use the name `run` since it conflicts with Minitest#run.
  def run_p(cmd)
    SystemPrivateAccessor.run_private(cmd)
  end

  def run_with_error_p(cmd)
    SystemPrivateAccessor.run_with_error_private(cmd)
  end
end
