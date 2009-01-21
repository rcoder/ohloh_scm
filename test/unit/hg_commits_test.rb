require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgCommitsTest < Scm::Test

		def test_commit
			with_hg_repository('hg') do |hg|
				assert_equal 4, hg.commit_count
				assert_equal 2, hg.commit_count('b14fa4692f949940bd1e28da6fb4617de2615484')
				assert_equal 0, hg.commit_count('75532c1e1f1de55c2271f6fd29d98efbe35397c4')

				assert_equal ['01101d8ef3cea7da9ac6e9a226d645f4418f05c9',
											'b14fa4692f949940bd1e28da6fb4617de2615484',
											'468336c6671cbc58237a259d1b7326866afc2817',
											'75532c1e1f1de55c2271f6fd29d98efbe35397c4'], hg.commit_tokens

				assert_equal ['75532c1e1f1de55c2271f6fd29d98efbe35397c4'],
					hg.commit_tokens('468336c6671cbc58237a259d1b7326866afc2817')

				assert_equal [], hg.commit_tokens('75532c1e1f1de55c2271f6fd29d98efbe35397c4')

				assert_equal ['01101d8ef3cea7da9ac6e9a226d645f4418f05c9',
											'b14fa4692f949940bd1e28da6fb4617de2615484',
											'468336c6671cbc58237a259d1b7326866afc2817',
											'75532c1e1f1de55c2271f6fd29d98efbe35397c4'], hg.commits.collect { |c| c.token }

				assert_equal ['75532c1e1f1de55c2271f6fd29d98efbe35397c4'],
					hg.commits('468336c6671cbc58237a259d1b7326866afc2817').collect { |c| c.token }

				# Check that the diffs are not populated
				assert_equal [], hg.commits('468336c6671cbc58237a259d1b7326866afc2817').first.diffs

				assert_equal [], hg.commits('75532c1e1f1de55c2271f6fd29d98efbe35397c4')
			end
		end

		def test_each_commit
			commits = []
			with_hg_repository('hg') do |hg|
				hg.each_commit do |c|
					assert c.token.length == 40
					assert c.committer_name
					assert c.committer_date.is_a?(Time)
					assert c.message.length > 0
					assert c.diffs.any?
					# Check that the diffs are populated
					c.diffs.each do |d|
						assert d.action =~ /^[MAD]$/
						assert d.path.length > 0
						assert d.sha1.length == 40
						assert d.parent_sha1.length == 40
					end
					commits << c
				end
				assert !FileTest.exist?(hg.log_filename) # Make sure we cleaned up after ourselves

				# Verify that we got the commits in forward chronological order
				assert_equal ['01101d8ef3cea7da9ac6e9a226d645f4418f05c9',
											'b14fa4692f949940bd1e28da6fb4617de2615484',
											'468336c6671cbc58237a259d1b7326866afc2817',
											'75532c1e1f1de55c2271f6fd29d98efbe35397c4'], commits.collect { |c| c.token }

				# Spot check that the diff sha1 and parent_sha1 are being computed correctly
				before_diff = commits[0].diffs.select { |d| d.path == 'helloworld.c' }.first
				assert_equal '4c734ad53b272c9b3d719f214372ac497ff6c068', before_diff.sha1
				assert_equal '0000000000000000000000000000000000000000', before_diff.parent_sha1

				after_diff = commits[2].diffs.select { |d| d.path == 'helloworld.c' }.first
				assert_equal 'f6adcae4447809b651c787c078d255b2b4e963c5', after_diff.sha1
				assert_equal before_diff.sha1, after_diff.parent_sha1
			end
		end
	end
end

