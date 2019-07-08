module GenericHelper
  def tmpdir(prefix = 'oh_scm_repo_')
    Dir.mktmpdir(prefix) { |path| yield path }
  end
end
