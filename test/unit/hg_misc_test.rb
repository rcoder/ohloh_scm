require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgMiscTest < Scm::Test

		def test_exist
			save_hg = nil
			with_hg_repository('hg') do |hg|
				save_hg = hg
				assert save_hg.exist?
			end
			assert !save_hg.exist?
		end

	end
end
