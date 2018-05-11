require_relative '../test_helper'

module OhlohScm::Adapters
	class SvnMiscTest < OhlohScm::Test

		def test_export
			with_svn_repository('svn') do |svn|
				OhlohScm::ScratchDir.new do |dir|
					svn.export(dir)
					assert_equal ['.','..','branches','tags','trunk'], Dir.entries(dir).sort
				end
			end
		end

    def test_export_tag
      with_svn_repository('svn', 'trunk') do |source_scm|
        OhlohScm::ScratchDir.new do |svn_working_folder|
          OhlohScm::ScratchDir.new do |dir|
            folder_name = source_scm.root.slice(/[^\/]+\/?\Z/)
            system "cd #{ svn_working_folder } && svn co #{ source_scm.root } && cd #{ folder_name } &&
                    mkdir -p #{ source_scm.root.gsub(/^file:../, '') }/db/transactions
                    svn copy trunk tags/2.0 && svn commit -m 'v2.0' && svn update"

            source_scm.export_tag(dir, '2.0')

            assert_equal ['.','..','COPYING','README','helloworld.c', 'makefile'], Dir.entries(dir).sort
          end
        end
      end
    end

		def test_ls_tree
			with_svn_repository('svn') do |svn|
				assert_equal ['branches/','tags/','trunk/','trunk/helloworld.c','trunk/makefile'], svn.ls_tree(2).sort
			end
		end

		def test_path
			assert !SvnAdapter.new(:url => "http://svn.collab.net/repos/svn/trunk").path
			assert !SvnAdapter.new(:url => "svn://svn.collab.net/repos/svn/trunk").path
			assert_equal "/foo/bar", SvnAdapter.new(:url => "file:///foo/bar").path
			assert_equal "foo/bar", SvnAdapter.new(:url => "file://foo/bar").path
			assert_equal "/foo/bar", SvnAdapter.new(:url => "svn+ssh://server/foo/bar").path
		end

		def test_hostname
			assert !SvnAdapter.new(:url => "http://svn.collab.net/repos/svn/trunk").hostname
			assert !SvnAdapter.new(:url => "svn://svn.collab.net/repos/svn/trunk").hostname
			assert !SvnAdapter.new(:url => "file:///foo/bar").hostname
			assert_equal "server", SvnAdapter.new(:url => "svn+ssh://server/foo/bar").hostname
		end

		def test_info
			with_svn_repository('svn') do |svn|
				assert_equal svn.url, svn.root
				assert_equal "6a9cefd4-a008-4d2a-a89b-d77e99cd6eb1", svn.uuid
				assert_equal 'directory', svn.node_kind

				assert_equal 'file', svn.node_kind('trunk/helloworld.c',1)
			end
		end

		def test_ls
			with_svn_repository('svn') do |svn|
				assert_equal ['branches/', 'tags/', 'trunk/'], svn.ls
				assert_equal ['COPYING','README','helloworld.c','makefile'], svn.ls('trunk')
				assert_equal ['helloworld.c'], svn.ls('trunk', 1)

				assert_equal ['trunk/helloworld.c'], svn.recurse_files(nil, 1)
				assert_equal ['helloworld.c'], svn.recurse_files('/trunk', 1)
			end
		end

		def test_is_directory
			with_svn_repository('svn') do |svn|
				assert svn.is_directory?('trunk')
				assert !svn.is_directory?('trunk/helloworld.c')
				assert !svn.is_directory?('invalid/path')
			end
		end

		def test_restrict_url_to_trunk_descend_no_further
			with_svn_repository('deep_svn') do |svn|
				assert_equal svn.root, svn.url
				assert_equal '', svn.branch_name

				svn.restrict_url_to_trunk

				assert_equal svn.root + '/trunk', svn.url
				assert_equal "/trunk", svn.branch_name
			end
		end

		def test_restrict_url_to_trunk
			with_svn_repository('svn') do |svn|
				assert_equal svn.root, svn.url
				assert_equal '', svn.branch_name

				svn.restrict_url_to_trunk

				assert_equal svn.root + '/trunk', svn.url
				assert_equal "/trunk", svn.branch_name
			end
		end

    def test_tags
      with_svn_repository('svn', 'trunk') do |source_scm|
        OhlohScm::ScratchDir.new do |svn_working_folder|
          folder_name = source_scm.root.slice(/[^\/]+\/?\Z/)
          system "cd #{ svn_working_folder } && svn co #{ source_scm.root } && cd #{ folder_name } &&
                  mkdir -p #{ source_scm.root.gsub(/^file:../, '') }/db/transactions
                  svn copy trunk tags/2.0 && svn commit -m 'v2.0' && svn update"

          assert_equal(['2.0', '6'], source_scm.tags.first[0..1])
          # Avoid millisecond comparision.
          assert_equal(Time.now.strftime('%F %R'), source_scm.tags.first[-1].strftime('%F %R'))
        end
      end
    end

    def test_tags_with_whitespaces
      with_svn_repository('svn', 'trunk') do |source_scm|
        OhlohScm::ScratchDir.new do |svn_working_folder|
          folder_name = source_scm.root.slice(/[^\/]+\/?\Z/)
          system "cd #{ svn_working_folder } && svn co #{ source_scm.root } && cd #{ folder_name } &&
                  mkdir -p #{ source_scm.root.gsub(/^file:../, '') }/db/transactions
                  svn copy trunk tags/'HL7 engine' && svn commit -m 'v2.0' && svn update && svn propset svn:date --revprop -r 'HEAD' 2016-02-12T00:44:04.921324Z"

          assert_equal(['HL7 engine', '6'], source_scm.tags.first[0..1])
          # Avoid millisecond comparision.
          assert_equal('2016-02-12', source_scm.tags.first[-1].strftime('%F'))
        end
      end
    end

    def test_tags_with_non_tagged_repository
      with_svn_repository('svn') do |svn|
        assert_equal svn.tags, []
      end
    end
  end
end
