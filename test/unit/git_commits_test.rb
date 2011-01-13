require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class GitCommitsTest < Scm::Test

		def test_commit_count
			with_git_repository('git') do |git|
				assert_equal 4, git.commit_count
				assert_equal 2, git.commit_count(:since => 'b6e9220c3cabe53a4ed7f32952aeaeb8a822603d')
				assert_equal 0, git.commit_count(:since => '1df547800dcd168e589bb9b26b4039bff3a7f7e4')
			end
		end

		def test_commit_tokens
			with_git_repository('git') do |git|
				assert_equal ['089c527c61235bd0793c49109b5bd34d439848c6',
											'b6e9220c3cabe53a4ed7f32952aeaeb8a822603d',
											'2e9366dd7a786fdb35f211fff1c8ea05c51968b1',
											'1df547800dcd168e589bb9b26b4039bff3a7f7e4'], git.commit_tokens

				assert_equal ['1df547800dcd168e589bb9b26b4039bff3a7f7e4'],
					git.commit_tokens(:since => '2e9366dd7a786fdb35f211fff1c8ea05c51968b1')

				assert_equal [], git.commit_tokens(:since => '1df547800dcd168e589bb9b26b4039bff3a7f7e4')
			end
		end

		def test_commits
			with_git_repository('git') do |git|
				assert_equal ['089c527c61235bd0793c49109b5bd34d439848c6',
											'b6e9220c3cabe53a4ed7f32952aeaeb8a822603d',
											'2e9366dd7a786fdb35f211fff1c8ea05c51968b1',
											'1df547800dcd168e589bb9b26b4039bff3a7f7e4'], git.commits.collect { |c| c.token }

				assert_equal ['1df547800dcd168e589bb9b26b4039bff3a7f7e4'],
					git.commits(:since => '2e9366dd7a786fdb35f211fff1c8ea05c51968b1').collect { |c| c.token }

				assert_equal [], git.commits(:since => '1df547800dcd168e589bb9b26b4039bff3a7f7e4')
			end
		end

    def test_trunk_only_commit_count
			with_git_repository('git_dupe_delete') do |git|
				assert_equal 4, git.commit_count(:trunk_only => false)
				assert_equal 3, git.commit_count(:trunk_only => true)
			end
		end

		def test_trunk_only_commit_tokens
			with_git_repository('git_dupe_delete') do |git|
				assert_equal ['a0a2b8623941562031a7d7f95d984feb4a2d719c',
                      'ad6bb43112706c462e53a9a8a8cd3b05f8e9260f',
                      '6126337d2497806528fd8657181d5d4afadd72a4', # On branch
                      '41c4b1044ebffc968d363e5f5e883134e624f846'],
          git.commit_tokens(:trunk_only => false)

				assert_equal ['a0a2b8623941562031a7d7f95d984feb4a2d719c',
                      'ad6bb43112706c462e53a9a8a8cd3b05f8e9260f',
                      # '6126337d2497806528fd8657181d5d4afadd72a4', # On branch
                      '41c4b1044ebffc968d363e5f5e883134e624f846'],
          git.commit_tokens(:trunk_only => true)
			end
		end

		def test_trunk_only_commit_tokens_using_since
			with_git_repository('git_dupe_delete') do |git|
				assert_equal ['ad6bb43112706c462e53a9a8a8cd3b05f8e9260f',
                      '41c4b1044ebffc968d363e5f5e883134e624f846'],
				  git.commit_tokens(
            :since => 'a0a2b8623941562031a7d7f95d984feb4a2d719c',
            :trunk_only => true)

				# All trunk commit_tokens, with :since == HEAD
				assert_equal [], git.commit_tokens(
          :since => '41c4b1044ebffc968d363e5f5e883134e624f846',
          :trunk_only => true)
			end
		end

		def test_trunk_only_commits
			with_git_repository('git_dupe_delete') do |git|
				assert_equal ['a0a2b8623941562031a7d7f95d984feb4a2d719c',
                      'ad6bb43112706c462e53a9a8a8cd3b05f8e9260f',
                      # The following commit is on a branch and should be excluded
                      # '6126337d2497806528fd8657181d5d4afadd72a4',
                      '41c4b1044ebffc968d363e5f5e883134e624f846'],
          git.commits(:trunk_only => true).collect { |c| c.token }
			end
		end

		def test_trunk_only_commits_using_since
			with_git_repository('git_dupe_delete') do |git|
				assert_equal ['ad6bb43112706c462e53a9a8a8cd3b05f8e9260f',
                      '41c4b1044ebffc968d363e5f5e883134e624f846'],
					git.commits(:since => 'a0a2b8623941562031a7d7f95d984feb4a2d719c',
                      :trunk_only => true).collect { |c| c.token }

				assert_equal [], git.commit_tokens(
          :since => '41c4b1044ebffc968d363e5f5e883134e624f846',
          :trunk_only => true)
			end
    end

	end
end
