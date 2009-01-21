require File.dirname(__FILE__) + '/../test_helper'

module Scm::Adapters
	class HgPushTest < Scm::Test

		def test_hostname
			assert_equal "foo", HgAdapter.new(:url => 'foo:/bar').hostname
			assert_equal "/bar", HgAdapter.new(:url => 'foo:/bar').path

			assert !HgAdapter.new.hostname
			assert !HgAdapter.new(:url => '/bar').hostname
			assert_equal 'http', HgAdapter.new(:url => 'http://www.ohloh.net/bar').hostname
		end

		def test_local
			assert !HgAdapter.new(:url => "foo:/bar").local? # Assuming your machine is not named "foo" :-)
			assert !HgAdapter.new(:url => "http://www.ohloh.net/foo").local?
			assert HgAdapter.new(:url => "src").local?
			assert HgAdapter.new(:url => "/Users/robin/src").local?
			assert HgAdapter.new(:url => "#{Socket.gethostname}:src").local?
			assert HgAdapter.new(:url => "#{Socket.gethostname}:/Users/robin/src").local?
		end

		def test_push
			with_hg_repository('hg') do |src|
				Scm::ScratchDir.new do |dest_dir|

					dest = HgAdapter.new(:url => dest_dir).normalize
					assert !dest.exist?

					src.push(dest)
					assert dest.exist?
					assert_equal src.log, dest.log

					# Commit some new code on the original and pull again
					src.run "cd '#{src.url}' && touch foo && hg add foo && hg commit -u test -m test"
					assert_equal "test\n", src.commits.last.message

					src.push(dest)
					assert_equal src.log, dest.log
				end
			end
		end

	end
end
