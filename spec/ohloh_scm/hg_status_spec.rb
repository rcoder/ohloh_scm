require 'spec_helper'

describe 'HgStatus' do
  it 'exist? must check if repo exists' do
    hg_repo = nil
    with_hg_repository('hg') do |hg|
      hg_repo = hg
      assert hg_repo.status.exist?
    end
    refute hg_repo.status.exist?
  end

  describe 'validate url' do
    it 'must have errors for invalid urls' do
      assert_url_error(nil, '', 'foo', 'http:/', 'http:://', 'http://', 'http://a')
      assert_url_error('www.selenic.com/repo/hello') # missing a protool prefix
      assert_url_error('http://www.selenic.com/repo/hello%20world') # no encoded strings allowed
      assert_url_error('http://www.selenic.com/repo/hello world') # no spaces allowed
      assert_url_error('git://www.selenic.com/repo/hello') # git protocol not allowed
      assert_url_error('svn://www.selenic.com/repo/hello') # svn protocol not allowed
      assert_url_error('/home/robin/hg')
      assert_url_error('file:///home/robin/hg')
      assert_url_error('ssh://robin@localhost/home/robin/hg')
      assert_url_error('ssh://localhost/home/robin/hg')
    end

    it 'wont have errors for valid urls' do
      assert_url_valid('http://www.selenic.com/repo/hello')
      assert_url_valid('http://www.selenic.com:80/repo/hello')
      assert_url_valid('https://www.selenic.com/repo/hello')
    end
  end

  def assert_url_error(*urls)
    urls.each do |url|
      base = OhlohScm::Factory.get_base(scm_type: :hg, url: url)
      base.status.send(:url_errors).wont_be :empty?
    end
  end

  def assert_url_valid(url)
    base = OhlohScm::Factory.get_base(scm_type: :hg, url: url)
    base.status.send(:url_errors).must_be_nil
  end
end
