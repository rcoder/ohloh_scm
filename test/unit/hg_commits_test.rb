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
	end
end

