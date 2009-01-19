require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class SvnCatFileTest < Scm::Test

		def test_cat_file
			with_svn_repository('svn') do |svn|
expected = <<-EXPECTED
/* Hello, World! */
#include <stdio.h>
main()
{
	printf("Hello, World!\\n");
}
EXPECTED
				assert_equal expected, svn.cat_file(Scm::Commit.new(:token => "1"), Scm::Diff.new(:path => "trunk/helloworld.c"))
			end

		end
	end
end
