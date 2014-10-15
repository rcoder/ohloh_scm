require_relative '../test_helper'

module OhlohScm::Adapters
  class SvnPatchTest < Scm::Test
    def test_patch_for_commit
      with_svn_repository('svn') do |repo|
        commit = repo.verbose_commit(2)
        data = File.read(File.join(DATA_DIR, 'svn_patch.diff'))
        assert_equal data, repo.patch_for_commit(commit)
      end
    end
  end
end

