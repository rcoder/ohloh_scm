require_relative '../test_helper'

module OhlohScm::Adapters
	class GitHeadTest < OhlohScm::Test

		def test_head_and_parents
			with_git_repository('git') do |git|
				assert git.exist?
				assert_equal '1df547800dcd168e589bb9b26b4039bff3a7f7e4', git.head_token
				assert_equal '1df547800dcd168e589bb9b26b4039bff3a7f7e4', git.head.token
				assert git.head.diffs.any?

				assert_equal '2e9366dd7a786fdb35f211fff1c8ea05c51968b1', git.parents(git.head).first.token
				assert git.parents(git.head).first.diffs.any?
			end
		end

    def test_head_token
      with_git_repository('git_with_invalid_encoding') do |git|
        assert_nothing_raised do
          git.head_token
        end
      end
    end
	end
end
