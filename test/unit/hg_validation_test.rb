require_relative '../test_helper'

module OhlohScm::Adapters
	class HgValidationTest < Scm::Test
		def test_rejected_urls
			[	nil, "", "foo", "http:/", "http:://", "http://", "http://a",
				"www.selenic.com/repo/hello", # missing a protool prefix
				"http://www.selenic.com/repo/hello%20world", # no encoded strings allowed
				"http://www.selenic.com/repo/hello world", # no spaces allowed
				"git://www.selenic.com/repo/hello", # git protocol not allowed
				"svn://www.selenic.com/repo/hello" # svn protocol not allowed
			].each do |url|
				hg = HgAdapter.new(:url => url, :public_urls_only => true)
				assert hg.validate_url.any?
			end
		end

		def test_accepted_urls
			[ "http://www.selenic.com/repo/hello",
				"http://www.selenic.com:80/repo/hello",
				"https://www.selenic.com/repo/hello",
			].each do |url|
				hg = HgAdapter.new(:url => url, :public_urls_only => true)
				assert !hg.validate_url
			end
		end

		# These urls are not available to the public
		def test_rejected_public_urls
			[ "file:///home/robin/hg",
				"/home/robin/hg",
				"ssh://robin@localhost/home/robin/hg",
				"ssh://localhost/home/robin/hg"
			].each do |url|
				hg = HgAdapter.new(:url => url, :public_urls_only => true)
				assert hg.validate_url

				hg = HgAdapter.new(:url => url)
				assert !hg.validate_url
			end
		end

		def test_guess_forge
			hg = HgAdapter.new(:url => nil)
			assert_equal nil, hg.guess_forge

			hg = HgAdapter.new(:url => "/home/robin/hg")
			assert_equal nil, hg.guess_forge

			hg = HgAdapter.new( :url => 'http://www.selenic.com/repo/hello')
			assert_equal 'www.selenic.com', hg.guess_forge

			hg = HgAdapter.new( :url => 'http://algoc.hg.sourceforge.net:8000/hgroot/algoc')
			assert_equal 'sourceforge.net', hg.guess_forge

			hg = HgAdapter.new( :url => 'http://poliqarp.sourceforge.net/hg/poliqarp/')
			assert_equal 'sourceforge.net', hg.guess_forge
		end
	end
end
