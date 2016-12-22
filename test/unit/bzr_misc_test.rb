# encoding: utf-8
require_relative '../test_helper'

module OhlohScm::Adapters
	class BzrMiscTest < OhlohScm::Test

		def test_exist
			save_bzr = nil
			with_bzr_repository('bzr') do |bzr|
				save_bzr = bzr
				assert save_bzr.exist?
			end
			assert !save_bzr.exist?
		end

		def test_ls_tree
			with_bzr_repository('bzr') do |bzr|
				assert_equal ['Cédric.txt',
                'file1.txt',
					      'file3.txt',
					      'file4.txt',
					      'file5.txt'],
              bzr.ls_tree(bzr.head_token).sort.map { |filename|
                filename.force_encoding(Encoding::UTF_8) }
			end
		end

		def test_export
			with_bzr_repository('bzr') do |bzr|
				OhlohScm::ScratchDir.new do |dir|
					bzr.export(dir)
					assert_equal ['.', '..', 'Cédric.txt', 'file1.txt', 'file3.txt', 'file4.txt', 'file5.txt'], Dir.entries(dir).sort
				end
			end
		end

    def test_tags
      with_bzr_repository('bzr') do |bzr|
        time_1 = Time.parse('2009-02-04 00:25:40 +0000')
        time_2 = Time.parse('2011-12-22 18:37:33 +0000')
        monkey_patch_run_method_to_match_tag_patterns
        assert_equal [['v1.0.0', '5', time_1], ['v2.0.0','7', time_2]], bzr.tags
      end
    end

    private

    def monkey_patch_run_method_to_match_tag_patterns
      original_method = AbstractAdapter.method(:run)
      AbstractAdapter.send :define_method, :run do |command|
        if command =~ /bzr tags/
          # The output of `bzr tags` sometimes has tags referring to ? while sometimes has dotted separators.
          "0.11-1.1             ?\n0.14-1               ?\n....\n#{ original_method.call(command) }"
        else
          original_method.call(command)
        end
      end
    end
	end
end
