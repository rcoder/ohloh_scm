require 'spec_helper'

describe 'Cvs::Scm' do
  it 'must test symlink fixup' do
    scm = get_core(:cvs, url: ':pserver:anoncvs:@cvs.netbeans.org:/cvs').scm
    scm.normalize
    scm.url.must_equal ':pserver:anoncvs:@cvs.netbeans.org:/shared/data/ccvs/repository'

    scm = get_core(:cvs, url: ':pserver:anoncvs:@cvs.dev.java.net:/cvs').scm
    scm.normalize
    scm.url.must_equal ':pserver:anoncvs:@cvs.dev.java.net:/shared/data/ccvs/repository'

    scm = get_core(:cvs, url: ':PSERVER:ANONCVS:@CVS.DEV.JAVA.NET:/cvs').scm
    scm.normalize
    scm.url.must_equal ':PSERVER:ANONCVS:@CVS.DEV.JAVA.NET:/shared/data/ccvs/repository'

    scm = get_core(:cvs, url: ':pserver:anonymous:@cvs.gna.org:/cvs/eagleusb').scm
    scm.normalize
    scm.url.must_equal ':pserver:anonymous:@cvs.gna.org:/var/cvs/eagleusb'
  end

  it 'must test sync_pserver_username_password' do
    # Pull username only from url
    scm = get_core(:cvs, url: ':pserver:guest:@ohloh.net:/test').scm
    scm.normalize
    scm.url.must_equal ':pserver:guest:@ohloh.net:/test'
    scm.username.must_equal 'guest'
    scm.password.must_equal ''

    # Pull username and password from url
    scm = get_core(:cvs, url: ':pserver:guest:secret@ohloh.net:/test').scm
    scm.normalize

    scm.url.must_equal ':pserver:guest:secret@ohloh.net:/test'
    scm.username.must_equal 'guest'
    scm.password.must_equal 'secret'

    # Apply username and password to url
    scm = get_core(:cvs, url: ':pserver::@ohloh.net:/test', username: 'guest', password: 'secret').scm
    scm.normalize
    scm.url.must_equal ':pserver:guest:secret@ohloh.net:/test'
    scm.username.must_equal 'guest'
    scm.password.must_equal 'secret'

    # Passwords disagree, use :password attribute
    scm = get_core(:cvs, url: ':pserver:guest:old@ohloh.net:/test', username: 'guest', password: 'new').scm
    scm.normalize
    scm.url.must_equal ':pserver:guest:new@ohloh.net:/test'
    scm.username.must_equal 'guest'
    scm.password.must_equal 'new'
  end

  it 'must test guess_forge' do
    scm = get_core(:cvs, url: nil).scm
    scm.send(:guess_forge).must_be_nil

    scm = get_core(:cvs, url: 'garbage_in_garbage_out').scm
    scm.send(:guess_forge).must_be_nil

    scm = get_core(:cvs, url: ':pserver:anonymous:@boost.cvs.sourceforge.net:/cvsroot/boost').scm
    scm.send(:guess_forge).must_equal 'sourceforge.net'

    scm = get_core(:cvs, url: ':pserver:guest:@cvs.dev.java.net:/cvs').scm
    scm.send(:guess_forge).must_equal 'java.net'

    scm = get_core(:cvs, url: ':PSERVER:ANONCVS:@CVS.DEV.JAVA.NET:/cvs').scm
    scm.send(:guess_forge).must_equal 'java.net'

    scm = get_core(:cvs, url: ':pserver:guest:@colorchooser.dev.java.net:/cvs').scm
    scm.send(:guess_forge).must_equal 'java.net'
  end

  it 'must test local directory trim' do
    scm = get_core(:cvs, url: '/Users/robin/cvs_repo/', branch_name: 'simple').scm
    scm.send(:trim_directory, '/Users/robin/cvs_repo/simple/foo.rb').must_equal '/Users/robin/cvs_repo/simple/foo.rb'
  end

  it 'must test remote directory trim' do
    scm = get_core(:cvs, url: ':pserver:anonymous:@moodle.cvs.sourceforge.net:/cvsroot/moodle',
                         branch_name: 'contrib').scm
    scm.send(:trim_directory, '/cvsroot/moodle/contrib/foo.rb').must_equal 'foo.rb'
  end

  it 'must test remote directory trim with port number' do
    scm = get_core(:cvs, url: ':pserver:anoncvs:anoncvs@libvirt.org:2401/data/cvs', branch_name: 'libvirt').scm
    scm.send(:trim_directory, '/data/cvs/libvirt/docs/html/Attic').must_equal 'docs/html/Attic'
  end

  it 'must test ordered directory list' do
    scm = get_core(:cvs, url: ':pserver:anonymous:@moodle.cvs.sourceforge.net:/cvsroot/moodle',
                         branch_name: 'contrib').scm

    list = scm.send(:build_ordered_directory_list, ['/cvsroot/moodle/contrib/foo/bar'.intern,
                                                    '/cvsroot/moodle/contrib'.intern,
                                                    '/cvsroot/moodle/contrib/hello'.intern,
                                                    '/cvsroot/moodle/contrib/hello'.intern])
    list.size.must_equal 4
    list.must_equal ['', 'foo', 'hello', 'foo/bar']
  end

  it 'must test ordered directory list ignores Attic' do
    scm = get_core(:cvs, url: ':pserver:anonymous:@moodle.cvs.sourceforge.net:/cvsroot/moodle',
                         branch_name: 'contrib').scm

    list = scm.send(:build_ordered_directory_list, ['/cvsroot/moodle/contrib/foo/bar'.intern,
                                                    '/cvsroot/moodle/contrib/Attic'.intern,
                                                    '/cvsroot/moodle/contrib/hello/Attic'.intern])

    list.size.must_equal 4
    list.must_equal ['', 'foo', 'hello', 'foo/bar']
  end
end
