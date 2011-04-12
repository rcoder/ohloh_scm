require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class GitValidationTest < Scm::Test
		def test_rejected_urls
			[	nil, "", "foo", "http:/", "http:://", "http://", "http://a",
			"kernel.org/linux/linux.git", # missing a protocol prefix
			"http://kernel.org/linux/lin%32ux.git", # no encoded strings allowed
			"http://kernel.org/linux/linux.git malicious code", # no spaces allowed
			"svn://svn.mythtv.org/svn/trunk", # svn protocol is not allowed
			"/home/robin/cvs", # local file paths not allowed
			"file:///home/robin/cvs", # file protocol is not allowed
			":pserver:anonymous:@juicereceiver.cvs.sourceforge.net:/cvsroot/juicereceiver" # pserver is just wrong
			].each do |url|
				git = GitAdapter.new(:url => url)
				assert git.validate_url.any?
			end
		end

		def test_accepted_urls
			[ "http://kernel.org/pub/scm/git/git.git",
			"git://kernel.org/pub/scm/git/git.git",
			"https://kernel.org/pub/scm/git/git.git",
			"https://kernel.org:8080/pub/scm/git/git.git",
			"git://kernel.org/~foo/git.git",
			"http://git.onerussian.com/pub/deb/impose+.git"
			].each do |url|
				git = GitAdapter.new(:url => url)
				assert !git.validate_url
			end
		end

		def test_guess_forge
			git = GitAdapter.new(:url => nil)
			assert_equal nil, git.guess_forge

			git = GitAdapter.new(:url => 'git://methabot.git.sourceforge.net/gitroot/methabot')
			assert_equal 'sourceforge.net', git.guess_forge

			git = GitAdapter.new( :url => 'http://kernel.org/pub/scm/linux/kernel/git/stable/linux-2.6.17.y.git')
			assert_equal 'kernel.org', git.guess_forge
		end

    def test_read_only_url
      assert_equal nil, GitAdapter.new(:url => nil).read_only_url
      assert_equal '', GitAdapter.new(:url => '').read_only_url
      assert_equal 'foo', GitAdapter.new(:url => 'foo').read_only_url

      # A non-Github URL: no change
			assert_equal 'git://kernel.org/pub/scm/git/git.git',
        GitAdapter.new(:url => 'git://kernel.org/pub/scm/git/git.git').read_only_url

      # A Github read-write URL: converted to read-only
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'https://robinluckey@github.com/robinluckey/ohcount.git').read_only_url

      # A Github read-write URL: converted to read-only
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'git@github.com:robinluckey/ohcount.git').read_only_url

      # A Github read-only URL: no change
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'git@github.com:robinluckey/ohcount.git').read_only_url
    end

    def test_normalize_converts_to_read_only
      git = GitAdapter.new(:url => 'https://robinluckey@github.com/robinluckey/ohcount.git')
      git.normalize
      assert_equal 'git://github.com/robinluckey/ohcount.git', git.url
    end
	end
end
