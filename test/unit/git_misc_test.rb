require_relative '../test_helper'

module OhlohScm::Adapters
	class GitMiscTest < OhlohScm::Test

		def test_export
			with_git_repository('git') do |git|
				OhlohScm::ScratchDir.new do |dir|
					git.export(dir)
					assert_equal ['.','..','.gitignore','COPYING','README','helloworld.c','makefile','ohloh_token'], Dir.entries(dir).sort
				end
			end
		end

		def test_branches
			with_git_repository('git') do |git|
				assert_equal ['develop', 'master'], git.branches
				assert git.has_branch?('master')
			end
		end

		def test_ls_tree
			with_git_repository('git') do |git|
				assert_equal ['.gitignore','COPYING','README','helloworld.c','makefile','ohloh_token'], git.ls_tree(git.head_token).sort
			end
		end

		def test_is_merge_commit
			with_git_repository('git_walk') do |git|
				assert git.is_merge_commit?(OhlohScm::Commit.new(:token => 'f264fb40c340a415b305ac1f0b8f12502aa2788f'))
				assert !git.is_merge_commit?(OhlohScm::Commit.new(:token => 'd067161caae2eeedbd74976aeff5c4d8f1ccc946'))
			end
		end

    def test_branches_encoding
      with_git_repository('git_with_invalid_encoding') do |git|
        assert_equal true, git.branches.all? { |branch| branch.valid_encoding? }
      end
    end

    # `git ls-tree` returns filenames in valid utf8 regardless of their original form.
    def test_ls_tree_encoding
      with_git_repository('git_with_invalid_encoding') do |git|
        assert_equal true, git.ls_tree.all? { |filename| filename.valid_encoding? }
      end
    end

    def test_tags
      with_git_repository('git') do |git|
        assert_equal git.tags, [['v1.0.0', 'f6e5a894ac4173f8f2a200f2c36df38a1e61121a', Time.parse('2016-07-31T07:58:30+05:30')],
                                ['v2.1.0', '1df547800dcd168e589bb9b26b4039bff3a7f7e4', Time.parse('2006-07-14T16:07:15-07:00')]]
      end
    end

    def test_tags_with_non_tagged_repository
      with_git_repository('git_walk') do |git|
        assert_equal git.tags, []
      end
    end
	end
end
