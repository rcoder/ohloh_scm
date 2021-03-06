require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class BzrValidationTest < Scm::Test
		def test_rejected_urls
			[	nil, "", "foo", "http:/", "http:://", "http://", "http://a",
				"www.selenic.com/repo/hello", # missing a protool prefix
				"http://www.selenic.com/repo/hello%20world", # no encoded strings allowed
				"http://www.selenic.com/repo/hello world", # no spaces allowed
				"git://www.selenic.com/repo/hello", # git protocol not allowed
				"svn://www.selenic.com/repo/hello" # svn protocol not allowed
			].each do |url|
				bzr = BzrAdapter.new(:url => url, :public_urls_only => true)
				assert bzr.validate_url.any?
			end
		end

		def test_accepted_urls
			[ "http://www.selenic.com/repo/hello",
				"http://www.selenic.com:80/repo/hello",
				"https://www.selenic.com/repo/hello",
			].each do |url|
				bzr = BzrAdapter.new(:url => url, :public_urls_only => true)
				assert !bzr.validate_url
			end
		end

		# These urls are not available to the public
		def test_rejected_public_urls
			[ "file:///home/test/bzr",
				"/home/test/bzr",
				"bzr+ssh://test@localhost/home/test/bzr",
				"bzr+ssh://localhost/home/test/bzr"
			].each do |url|
				bzr = BzrAdapter.new(:url => url, :public_urls_only => true)
				assert bzr.validate_url

				bzr = BzrAdapter.new(:url => url)
				assert !bzr.validate_url
			end
		end

		def test_guess_forge
			bzr = BzrAdapter.new(:url => nil)
			assert_equal nil, bzr.guess_forge

			bzr = BzrAdapter.new(:url => "/home/test/bzr")
			assert_equal nil, bzr.guess_forge

			bzr = BzrAdapter.new( :url => 'http://www.selenic.com/repo/hello')
			assert_equal 'www.selenic.com', bzr.guess_forge
		end
	end
end
