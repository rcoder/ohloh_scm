require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class GitMiscTest < Scm::Test

		def test_export
			with_git_repository('git') do |git|
				Scm::ScratchDir.new do |dir|
					git.export(dir)
					assert_equal ['.','..','.gitignore','COPYING','README','helloworld.c','makefile','ohloh_token'], Dir.entries(dir).sort
				end
			end
		end

		def test_branches
			with_git_repository('git') do |git|
				assert_equal ['master'], git.branches
				assert git.has_branch?('master')
			end
		end

		def test_ls_tree
			with_git_repository('git') do |git|
				assert_equal ['.gitignore','COPYING','README','helloworld.c','makefile','ohloh_token'], git.ls_tree(git.head_token).sort
			end
		end

	end
end
