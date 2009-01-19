require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class GitCommitsTest < Scm::Test

		def test_commit
			with_git_repository('git') do |git|
				assert_equal 4, git.commit_count
				assert_equal 2, git.commit_count('b6e9220c3cabe53a4ed7f32952aeaeb8a822603d')
				assert_equal 0, git.commit_count('1df547800dcd168e589bb9b26b4039bff3a7f7e4')

				assert_equal ['089c527c61235bd0793c49109b5bd34d439848c6',
											'b6e9220c3cabe53a4ed7f32952aeaeb8a822603d',
											'2e9366dd7a786fdb35f211fff1c8ea05c51968b1',
											'1df547800dcd168e589bb9b26b4039bff3a7f7e4'], git.commit_tokens

				assert_equal ['1df547800dcd168e589bb9b26b4039bff3a7f7e4'],
					git.commit_tokens('2e9366dd7a786fdb35f211fff1c8ea05c51968b1')

				assert_equal [], git.commit_tokens('1df547800dcd168e589bb9b26b4039bff3a7f7e4')

				assert_equal ['089c527c61235bd0793c49109b5bd34d439848c6',
											'b6e9220c3cabe53a4ed7f32952aeaeb8a822603d',
											'2e9366dd7a786fdb35f211fff1c8ea05c51968b1',
											'1df547800dcd168e589bb9b26b4039bff3a7f7e4'], git.commits.collect { |c| c.token }

				assert_equal ['1df547800dcd168e589bb9b26b4039bff3a7f7e4'],
					git.commits('2e9366dd7a786fdb35f211fff1c8ea05c51968b1').collect { |c| c.token }

				assert_equal [], git.commits('1df547800dcd168e589bb9b26b4039bff3a7f7e4')
			end
		end

	end
end
