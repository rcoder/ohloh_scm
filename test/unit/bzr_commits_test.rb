require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class BzrCommitsTest < Scm::Test

		def test_commit_count
			with_bzr_repository('bzr') do |bzr|
				assert_equal 6, bzr.commit_count
				assert_equal 6, bzr.commit_count(0)
				assert_equal 5, bzr.commit_count(1)
				assert_equal 1, bzr.commit_count(5)
				assert_equal 0, bzr.commit_count(6)
			end
		end

		def test_commit_tokens
			with_bzr_repository('bzr') do |bzr|
				assert_equal ['1', '2', '3', '4', '5', '6'], bzr.commit_tokens
				assert_equal ['2', '3', '4', '5', '6'], bzr.commit_tokens(1)
				assert_equal ['6'], bzr.commit_tokens(5)
				assert_equal [], bzr.commit_tokens(6)
			end
		end

		def test_commits
			with_bzr_repository('bzr') do |bzr|
				assert_equal ['1', '2', '3', '4', '5', '6'], bzr.commits.collect { |c| c.token }
				assert_equal ['6'], bzr.commits(5).collect { |c| c.token }
				assert_equal [], bzr.commits(6).collect { |c| c.token }

				# Check that the diffs are not populated
				assert_equal [], bzr.commits.first.diffs
			end
		end

		def test_each_commit
			with_bzr_repository('bzr') do |bzr|
				commits = []
				bzr.each_commit do |c|
					assert c.committer_name
					assert c.committer_date.is_a?(Time)
					assert c.message.length > 0
					assert c.diffs.any?
					# Check that the diffs are populated
					c.diffs.each do |d|
						assert d.action =~ /^[MAD]$/
						assert d.path.length > 0
					end
					commits << c
				end

				# Make sure we cleaned up after ourselves
				assert !FileTest.exist?(bzr.log_filename)

				# Verify that we got the commits in forward chronological order
				assert_equal ['1', '2', '3', '4', '5', '6'], commits.collect{ |c| c.token }
			end
		end
	end
end

