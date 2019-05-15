require 'spec_helper'

describe 'HgStatus' do
  describe 'validate_server_connection' do
    it 'must handle non existent remote source' do
      core = OhlohScm::Factory.get_core(scm_type: :hg, url: 'http://www.selenic.com/repo/foobar')
      core.status.validate_server_connection
      core.status.errors.wont_be :empty?
    end
  end

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
      assert_url_error(:hg, nil, '', 'foo', 'http:/', 'http:://', 'http://', 'http://a')
      assert_url_error(:hg, 'www.selenic.com/repo/hello') # missing a protool prefix
      assert_url_error(:hg, 'http://www.selenic.com/repo/hello%20world') # no encoded strings allowed
      assert_url_error(:hg, 'http://www.selenic.com/repo/hello world') # no spaces allowed
      assert_url_error(:hg, 'git://www.selenic.com/repo/hello') # git protocol not allowed
      assert_url_error(:hg, 'svn://www.selenic.com/repo/hello') # svn protocol not allowed
      assert_url_error(:hg, '/home/robin/hg')
      assert_url_error(:hg, 'file:///home/robin/hg')
      assert_url_error(:hg, 'ssh://robin@localhost/home/robin/hg')
      assert_url_error(:hg, 'ssh://localhost/home/robin/hg')
    end

    it 'wont have errors for valid urls' do
      assert_url_valid(:hg, 'http://www.selenic.com/repo/hello')
      assert_url_valid(:hg, 'http://www.selenic.com:80/repo/hello')
      assert_url_valid(:hg, 'https://www.selenic.com/repo/hello')
    end
  end
end
