require_relative '../test_helper'

module OhlohScm::Adapters
  class HgPatchTest < Scm::Test
    def test_patch_for_commit
      with_hg_repository('hg') do |repo|
        commit = repo.verbose_commit(1)
        data = File.read(File.join(DATA_DIR, 'hg_patch.diff'))
        assert_equal data, repo.patch_for_commit(commit)
      end
    end
  end
end

