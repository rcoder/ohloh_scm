require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class BzrHeadTest < Scm::Test

		def test_head_and_parents
			with_bzr_repository('bzr') do |bzr|
				assert_equal '6', bzr.head_token
				assert_equal '6', bzr.head.token
				assert bzr.head.diffs.any? # diffs should be populated

				assert_equal '5', bzr.parents(bzr.head).first.token
				assert bzr.parents(bzr.head).first.diffs.any?
			end
		end

	end
end
