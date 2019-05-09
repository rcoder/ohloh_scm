require 'spec_helper'

describe 'GitStatus' do
  it 'branch?' do
    with_git_repository('git') do |git|
      git.activity.send(:branches).must_equal %w[develop master]
      assert git.status.branch? # checks master.
      assert git.status.branch?('develop')
    end
  end

  describe 'validate_server_connection' do
    it 'must handle non existent remote source' do
      base = OhlohScm::Factory.get_base(scm_type: :git, url: 'https://github.com/Person/foobar')
      base.status.validate_server_connection
      base.status.errors.wont_be :empty?
    end
  end

  describe 'valid?' do
    it 'must have no errors for valid url' do
      base = OhlohScm::Factory.get_base(scm_type: :git, url: 'https://github.com/ruby/ruby')
      base.status.must_be :valid?
    end
  end

  it 'must have errors for invalid branch_name' do
    get_base(:git, branch_name: 'x' * 81).status.send(:branch_name_errors).wont_be :empty?
    get_base(:git, branch_name: 'foo@bar').status.send(:branch_name_errors).wont_be :empty?
  end

  it 'must have errors for invalid username' do
    get_base(:git, username: 'x' * 33).status.send(:username_errors).wont_be :empty?
    get_base(:git, username: 'foo@bar').status.send(:username_errors).wont_be :empty?
  end

  it 'must have errors for invalid password' do
    get_base(:git, password: 'x' * 33).status.send(:password_errors).wont_be :empty?
    get_base(:git, password: 'escape').status.send(:password_errors).wont_be :empty?
  end

  describe 'validate url' do
    it 'must have errors for invalid urls' do
      assert_url_error(:git, nil, '', 'foo', 'http:/', 'http:://', 'http://', 'http://a')
      assert_url_error(:git, 'kernel.org/linux/linux.git') # missing a protocol prefix
      assert_url_error(:git, 'http://kernel.org/linux/lin%32ux.git') # no encoded strings allowed
      assert_url_error(:git, 'http://kernel.org/linux/linux.git malicious code') # no spaces allowed
      assert_url_error(:git, 'svn://svn.mythtv.org/svn/trunk') # svn protocol is not allowed
      assert_url_error(:git, '/home/robin/cvs') # local file paths not allowed
      assert_url_error(:git, 'file:///home/robin/cvs') # file protocol is not allowed
      # pserver is just wrong
      assert_url_error(:git, ':pserver:anonymous:@juicereceiver.cvs.sourceforge.net:/cvsroot/juicereceiver')
    end

    it 'wont have errors for valid urls' do
      assert_url_valid(:git, 'http://kernel.org/pub/scm/git/git.git')
      assert_url_valid(:git, 'git://kernel.org/pub/scm/git/git.git')
      assert_url_valid(:git, 'https://kernel.org/pub/scm/git/git.git')
      assert_url_valid(:git, 'https://kernel.org:8080/pub/scm/git/git.git')
      assert_url_valid(:git, 'git://kernel.org/~foo/git.git')
      assert_url_valid(:git, 'http://git.onerussian.com/pub/deb/impose+.git')
      assert_url_valid(:git, 'https://Person@github.com/Person/some_repo.git')
      assert_url_valid(:git, 'http://Person@github.com/Person/some_repo.git')
      assert_url_valid(:git, 'https://github.com/Person/some_repo')
      assert_url_valid(:git, 'http://github.com/Person/some_repo')
    end
  end
end
