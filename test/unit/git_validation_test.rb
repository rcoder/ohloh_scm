require_relative '../test_helper'

module OhlohScm::Adapters
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
			"http://git.onerussian.com/pub/deb/impose+.git",
      "https://Person@github.com/Person/some_repo.git",
      "http://Person@github.com/Person/some_repo.git",
      "https://github.com/Person/some_repo",
      "http://github.com/Person/some_repo"
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

    def test_normalize_url
      assert_equal nil, GitAdapter.new(:url => nil).normalize_url
      assert_equal '', GitAdapter.new(:url => '').normalize_url
      assert_equal 'foo', GitAdapter.new(:url => 'foo').normalize_url

      # A non-Github URL: no change
			assert_equal 'git://kernel.org/pub/scm/git/git.git',
        GitAdapter.new(:url => 'git://kernel.org/pub/scm/git/git.git').normalize_url

      # A Github read-write URL: converted to read-only
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'https://robinluckey@github.com/robinluckey/ohcount.git').normalize_url

      # A Github read-write URL: converted to read-only
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'git@github.com:robinluckey/ohcount.git').normalize_url

      # A Github read-only URL: no change
      assert_equal 'git://github.com/robinluckey/ohcount.git',
        GitAdapter.new(:url => 'git@github.com:robinluckey/ohcount.git').normalize_url
    end

    def test_normalize_converts_to_read_only
      normalize_url_test('https://robinluckey@github.com/robinluckey/ohcount.git', 'git://github.com/robinluckey/ohcount.git')
    end

    def test_normalize_handles_https_with_user_at_github_format
      normalize_url_test('http://Person@github.com/Person/something.git', 'git://github.com/Person/something.git')
    end

    def test_normalize_handles_https_web_url
      normalize_url_test('https://github.com/Person/something', 'git://github.com/Person/something')
    end

    def test_normalize_handles_http_web_url
      normalize_url_test('http://github.com/Person/something', 'git://github.com/Person/something')
    end

  private
    def normalize_url_test(url, result_url)
      git = GitAdapter.new(:url => url)
      git.normalize
      assert_equal result_url, git.url
     end
	end
end
