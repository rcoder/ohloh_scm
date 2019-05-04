module GenericHelper
  def tmpdir
    Dir.mktmpdir('oh_scm_repo_') { |path| yield path }
  end
end
