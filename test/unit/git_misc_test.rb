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

		def test_head
			with_git_repository('git') do |git|
				assert git.exist?
				assert_equal '1df547800dcd168e589bb9b26b4039bff3a7f7e4', git.head
				assert_equal ['master'], git.branches
				assert git.has_branch?('master')
			end
		end

	end
end
