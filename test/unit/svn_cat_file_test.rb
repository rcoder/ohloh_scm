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
				assert_equal expected, svn.cat_file(Scm::Commit.new(:token => 1), Scm::Diff.new(:path => "trunk/helloworld.c"))

				assert_equal nil, svn.cat_file(Scm::Commit.new(:token => 1), Scm::Diff.new(:path => "file not found"))
			end
		end

		def test_cat_file_with_chaining
goodbye = <<-EXPECTED
#include <stdio.h>
main()
{
	printf("Goodbye, world!\\n");
}
EXPECTED
			with_svn_repository('svn_with_branching', '/trunk') do |svn|
				# The first case asks for the file on the HEAD, so it should easily be found
				assert_equal goodbye, svn.cat_file(Scm::Commit.new(:token => 8), Scm::Diff.new(:path => "goodbyeworld.c"))

				# The next test asks for the file as it appeared before /branches/development was moved to /trunk,
				# so this request requires traversal up the chain to the parent SvnAdapter.
				assert_equal goodbye, svn.cat_file(Scm::Commit.new(:token => 5), Scm::Diff.new(:path => "goodbyeworld.c"))
			end
		end
	end
end
