require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class GitTokenTest < Scm::Test

		def test_no_token_returns_nil
			Scm::ScratchDir.new do |dir|
				git = GitAdapter.new(:url => dir).normalize
				assert !git.read_token
				git.init_db
				assert !git.read_token
			end
		end

		def test_write_and_read_token
			Scm::ScratchDir.new do |dir|
				git = GitAdapter.new(:url => dir).normalize
				git.init_db
				git.write_token("FOO")
				assert !git.read_token # Token not valid until committed
				git.commit_all(Scm::Commit.new)
				assert_equal "FOO", git.read_token
			end
		end

		def test_commit_all_includes_write_token
			Scm::ScratchDir.new do |dir|
				git = GitAdapter.new(:url => dir).normalize
				git.init_db
				c = Scm::Commit.new
				c.token = "BAR"
				git.commit_all(c)
				assert_equal c.token, git.read_token
			end
		end
	end
end
