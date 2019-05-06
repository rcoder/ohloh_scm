require 'spec_helper'

describe 'GitStatus' do
  it 'branch?' do
    with_git_repository('git') do |git|
      git.activity.send(:branches).must_equal %w[develop master]
      assert git.status.branch? # checks master.
      assert git.status.branch?('develop')
    end
  end

  describe 'valid?' do
    it 'must have no errors for valid url' do
      base = OhlohScm::Factory.get_base(scm_type: :git, url: 'https://github.com/ruby/ruby')
      base.status.must_be :valid?
    end
  end

  it 'must have errors for invalid branch_name' do
    get_base(branch_name: 'x' * 81).status.send(:branch_name_errors).wont_be :empty?
    get_base(branch_name: 'foo@bar').status.send(:branch_name_errors).wont_be :empty?
  end

  it 'must have errors for invalid username' do
    get_base(username: 'x' * 33).status.send(:username_errors).wont_be :empty?
    get_base(username: 'foo@bar').status.send(:username_errors).wont_be :empty?
  end

  it 'must have errors for invalid password' do
    get_base(password: 'x' * 33).status.send(:password_errors).wont_be :empty?
    get_base(password: 'escape').status.send(:password_errors).wont_be :empty?
  end

  describe 'validate url' do
    it 'must have errors for invalid urls' do
      assert_url_error(nil, '', 'foo', 'http:/', 'http:://', 'http://', 'http://a')
      assert_url_error('kernel.org/linux/linux.git') # missing a protocol prefix
      assert_url_error('http://kernel.org/linux/lin%32ux.git') # no encoded strings allowed
      assert_url_error('http://kernel.org/linux/linux.git malicious code') # no spaces allowed
      assert_url_error('svn://svn.mythtv.org/svn/trunk') # svn protocol is not allowed
      assert_url_error('/home/robin/cvs') # local file paths not allowed
      assert_url_error('file:///home/robin/cvs') # file protocol is not allowed
      # pserver is just wrong
      assert_url_error(':pserver:anonymous:@juicereceiver.cvs.sourceforge.net:/cvsroot/juicereceiver')
    end

    it 'wont have errors for valid urls' do
      assert_url_valid('http://kernel.org/pub/scm/git/git.git')
      assert_url_valid('git://kernel.org/pub/scm/git/git.git')
      assert_url_valid('https://kernel.org/pub/scm/git/git.git')
      assert_url_valid('https://kernel.org:8080/pub/scm/git/git.git')
      assert_url_valid('git://kernel.org/~foo/git.git')
      assert_url_valid('http://git.onerussian.com/pub/deb/impose+.git')
      assert_url_valid('https://Person@github.com/Person/some_repo.git')
      assert_url_valid('http://Person@github.com/Person/some_repo.git')
      assert_url_valid('https://github.com/Person/some_repo')
      assert_url_valid('http://github.com/Person/some_repo')
    end
  end

  def get_base(opts)
    OhlohScm::Factory.get_base({ scm_type: :git, url: 'foo' }.merge(opts))
  end

  def assert_url_error(*urls)
    urls.each do |url|
      base = OhlohScm::Factory.get_base(scm_type: :git, url: url)
      base.status.send(:url_errors).wont_be :empty?
    end
  end

  def assert_url_valid(url)
    base = OhlohScm::Factory.get_base(scm_type: :git, url: url)
    base.status.send(:url_errors).must_be_nil
  end
end
