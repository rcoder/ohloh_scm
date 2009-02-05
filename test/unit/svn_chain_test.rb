require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class SvnChainTest < Scm::Test

		def test_basic
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				# In this repository, /branches/development becomes
				# the /trunk in revision 8. So there should be no record
				# before revision 8 in the 'traditional' commit parser.
				assert_equal [8,9], svn.commit_tokens

				p = svn.parent_svn
				assert_equal p.url, svn.url
				assert_equal p.branch_name, '/branches/development'
				assert_equal p.final_revision, 7
			end
		end

	end
end
