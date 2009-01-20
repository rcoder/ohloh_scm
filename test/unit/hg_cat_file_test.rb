require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgCatFileTest < Scm::Test

		def test_cat_file
			with_hg_repository('hg') do |hg|
expected = <<-EXPECTED
/* Hello, World! */

/*
 * This file is not covered by any license, especially not
 * the GNU General Public License (GPL). Have fun!
 */

#include <stdio.h>
main()
{
	printf("Hello, World!\\n");
}
EXPECTED

				# The file was deleted in revision 468336c6671c. Check that it does not exist now, but existed in parent.
				assert_equal nil, hg.cat_file(Scm::Commit.new(:token => '75532c1e1f1d'), Scm::Diff.new(:path => 'helloworld.c'))
				assert_equal expected, hg.cat_parent_file(Scm::Commit.new(:token => '75532c1e1f1d'), Scm::Diff.new(:path => 'helloworld.c'))
				assert_equal expected, hg.cat_file(Scm::Commit.new(:token => '468336c6671c'), Scm::Diff.new(:path => 'helloworld.c'))
			end
		end

	end
end
