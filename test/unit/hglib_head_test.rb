require_relative '../test_helper'

module OhlohScm::Adapters
	class HgHeadTest < Scm::Test

		def test_head_and_parents
			with_hglib_repository('hg') do |hg|
				assert_equal '75532c1e1f1d', hg.head_token
				assert_equal '75532c1e1f1de55c2271f6fd29d98efbe35397c4', hg.head.token
				assert hg.head.diffs.any? # diffs should be populated

				assert_equal '468336c6671cbc58237a259d1b7326866afc2817', hg.parents(hg.head).first.token
				assert hg.parents(hg.head).first.diffs.any?
			end
		end

	end
end
