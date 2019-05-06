# frozen_string_literal: true

module RepositoryHelper
  def with_git_repository(name, branch_name = nil)
    with_repository(:git, name, branch_name) { |git| yield git }
  end

  def with_git_svn_repository(name)
    with_repository(:git_svn, name) { |svn| yield svn }
  end

  def with_cvs_repository(name, module_name = '')
    with_repository(:cvs, name, module_name) { |cvs| yield cvs }
  end

  def with_hg_repository(name, branch_name = nil)
    with_repository(:hg, name, branch_name) { |hg| yield hg }
  end

  def with_hg_lib_repository(name, branch_name = nil)
    with_repository(:hg_lib, name, branch_name) { |hg| yield hg }
  end

  def with_bzr_repository(name)
    with_repository(:bzr, name) { |bzr| yield bzr }
  end

  private

  def with_repository(scm_type, name, branch_name = nil)
    source_path = get_fixture_folder_path(name)
    Dir.mktmpdir('oh_scm_fixture_') do |dir_path|
      setup_repository_archive(source_path, dir_path)
      yield OhlohScm::Factory.get_base(scm_type: scm_type, url: File.join(dir_path, name),
                                       branch_name: branch_name)
    end
  end

  def setup_repository_archive(source_path, dir_path)
    if Dir.exist?(source_path)
      `cp -R #{source_path} #{dir_path}`
    elsif File.exist?("#{source_path}.tgz")
      `tar xzf #{source_path}.tgz --directory #{dir_path}`
    else
      raise "Repository archive #{source_path} not found."
    end
  end

  def get_fixture_folder_path(name)
    fixture_dir = File.expand_path('../scm_fixtures', __dir__)
    File.join(fixture_dir, name)
  end
end
