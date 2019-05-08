# frozen_string_literal: true

require 'spec_helper'

describe 'BzrStatus' do
  describe 'validate_server_connection' do
    it 'must handle non existent remote source' do
      base = OhlohScm::Factory.get_base(scm_type: :bzr, url: 'lp:foobar')
      base.status.validate_server_connection
      base.status.errors.wont_be :empty?
    end
  end

  describe 'validate url' do
    it 'must have errors for invalid urls' do
      assert_url_error(nil, '', 'foo', 'http:/', 'http:://', 'http://', 'http://a')
      assert_url_error('http://www.selenic.com/repo/hello%20world') # no encoded strings allowed
      assert_url_error('http://www.selenic.com/repo/hello world') # no spaces allowed
      assert_url_error('git://www.selenic.com/repo/hello') # git protocol not allowed
      assert_url_error('svn://www.selenic.com/repo/hello') # svn protocol not allowed
      assert_url_error('lp://foobar') # lp requires no '//' after colon
      assert_url_error('file:///home/test/bzr')
      assert_url_error('/home/test/bzr')
      assert_url_error('bzr+ssh://test@localhost/home/test/bzr')
      assert_url_error('bzr+ssh://localhost/home/test/bzr')
    end

    it 'wont have errors for valid urls' do
      assert_url_valid('http://www.selenic.com/repo/hello')
      assert_url_valid('http://www.selenic.com:80/repo/hello')
      assert_url_valid('https://www.selenic.com/repo/hello')
      assert_url_valid('bzr://www.selenic.com/repo/hello')
      assert_url_valid('lp:foobar')
      assert_url_valid('lp:~foobar/bar')
    end
  end

  def assert_url_error(*urls)
    urls.each do |url|
      base = OhlohScm::Factory.get_base(scm_type: :bzr, url: url)
      base.status.send(:url_errors).wont_be :empty?
    end
  end

  def assert_url_valid(url)
    base = OhlohScm::Factory.get_base(scm_type: :bzr, url: url)
    base.status.send(:url_errors).must_be_nil
  end
end
