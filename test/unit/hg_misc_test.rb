require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgMiscTest < Scm::Test

		def test_tip_and_parent
			save_hg = nil
			with_hg_repository('hg') do |hg|
				assert_equal '75532c1e1f1d', hg.tip_token
				assert_equal '75532c1e1f1d', hg.tip_commit.token
				assert_equal '468336c6671c', hg.parent_commit(hg.tip_commit).token
				save_hg = hg
				assert save_hg.exist?
			end
			assert !save_hg.exist?
		end

	end
end

