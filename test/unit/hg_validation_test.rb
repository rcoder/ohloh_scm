require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgValidationTest < Scm::Test
		def test_rejected_urls
			[	nil, "", "foo", "http:/", "http:://", "http://", "http://a",
				"www.selenic.com/repo/hello", # missing a protool prefix
				"http://www.selenic.com/repo/hello%20world", # no encoded strings allowed
				"http://www.selenic.com/repo/hello world", # no spaces allowed
				"git://www.selenic.com/repo/hello", # git protocol not allowed
				"svn://www.selenic.com/repo/hello", # svn protocol not allowed
				"/home/robin/hg", # local file paths not allowed
				"file:///home/robin/hg" # file protocol is not allowed
			].each do |url|
				hg = HgAdapter.new(:url => url)
				assert hg.validate_url.any?
			end
		end

		def test_accepted_urls
			[ "http://www.selenic.com/repo/hello",
				"https://www.selenic.com/repo/hello",
			].each do |url|
				hg = HgAdapter.new(:url => url)
				assert !hg.validate_url
			end
		end

		def test_guess_forge
			hg = HgAdapter.new(:url => nil)
			assert_equal nil, hg.guess_forge

			hg = HgAdapter.new( :url => 'http://www.selenic.com/repo/hello')
			assert_equal 'www.selenic.com', hg.guess_forge
		end
	end
end
