require_relative '../test_helper'

module OhlohScm::Adapters
  class GitPatchTest < OhlohScm::Test
    def test_patch_for_commit
      with_git_repository('git') do |repo|
        commit = repo.verbose_commit('b6e9220c3cabe53a4ed7f32952aeaeb8a822603d')
        data = File.read(File.join(DATA_DIR, 'git_patch.diff'))
        assert_equal data, repo.patch_for_commit(commit)
      end
    end
  end
end

