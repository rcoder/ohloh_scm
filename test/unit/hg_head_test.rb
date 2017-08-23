require_relative '../test_helper'

module OhlohScm::Adapters
	class HgHeadTest < OhlohScm::Test

		def test_hg_head_and_parents
			with_hg_repository('hg') do |hg|
				assert_equal '655f04cf6ad708ab58c7b941672dce09dd369a18', hg.head_token
				assert_equal '655f04cf6ad708ab58c7b941672dce09dd369a18', hg.head.token
				assert hg.head.diffs.any? # diffs should be populated

				assert_equal '75532c1e1f1de55c2271f6fd29d98efbe35397c4', hg.parents(hg.head).first.token
				assert hg.parents(hg.head).first.diffs.any?
			end
		end

    def test_head_with_branch
      with_hg_repository('hg', 'develop') do |hg|
        assert_equal '4d54c3f0526a1ec89214a70615a6b1c6129c665c', hg.head.token
        assert hg.head.diffs.any?
      end
    end
	end
end
