require_relative '../test_helper'

module OhlohScm::Parsers
	class CvsParserTest < OhlohScm::Test

		def test_basic
			assert_convert(CvsParser, DATA_DIR + '/basic.rlog', DATA_DIR + '/basic.ohlog')
		end

		def test_empty_array
			assert_equal([], CvsParser.parse(''))
		end

		def test_empty_xml
			assert_equal("<?xml version=\"1.0\"?>\n<ohloh_log scm=\"cvs\">\n</ohloh_log>\n", CvsParser.parse('', :writer => XmlWriter.new))
		end

		def test_log_parser
			revisions = CvsParser.parse File.read(DATA_DIR + '/basic.rlog')

			assert_equal 2, revisions.size

			assert_equal '2005/07/25 17:09:59', revisions[0].token
			assert_equal 'pizzandre', revisions[0].committer_name
			assert_equal Time.utc(2005,07,25,17,9,59), revisions[0].committer_date
			assert_equal '*** empty log message ***', revisions[0].message

			assert_equal '2005/07/25 17:11:06', revisions[1].token
			assert_equal 'pizzandre', revisions[1].committer_name
			assert_equal Time.utc(2005,07,25,17,11,6), revisions[1].committer_date
			assert_equal 'Addin UNL file with using example-', revisions[1].message
		end

		# One file with several revisions
		def test_multiple_revisions
			revisions = CvsParser.parse File.read(DATA_DIR + '/multiple_revisions.rlog')

			# There are 9 revisions in the rlog, but some of them are close together with the same message.
			# Therefore we bin them together into only 7 revisions.
			assert_equal 7, revisions.size

			assert_equal '2005/07/15 11:53:30', revisions[0].token
			assert_equal 'httpd', revisions[0].committer_name
			assert_equal 'Initial data for the intelliglue project', revisions[0].message

			assert_equal '2005/07/15 16:40:17', revisions[1].token
			assert_equal 'pizzandre', revisions[1].committer_name
			assert_equal '*** empty log message ***', revisions[1].message

			assert_equal '2005/07/26 20:35:13', revisions[5].token
			assert_equal 'pizzandre', revisions[5].committer_name
			assert_equal "Issue number:\nObtained from:\nSubmitted by:\nReviewed by:\nAdding current milestones-", revisions[5].message

			assert_equal '2005/07/26 20:39:16', revisions[6].token
			assert_equal 'pizzandre', revisions[6].committer_name
			assert_equal "Issue number:\nObtained from:\nSubmitted by:\nReviewed by:\nCompleting and fixing milestones texts", revisions[6].message
		end

		# A file is created and modified on the branch, then merged to the trunk, then deleted from the branch.
		# From the trunk's point of view, we should see only the merge event.
		def test_file_created_on_branch_as_seen_from_trunk
			revisions = CvsParser.parse File.read(DATA_DIR + '/file_created_on_branch.rlog'), :branch_name => 'HEAD'
			assert_equal 1, revisions.size
			assert_equal 'merged new_file.rb from branch onto the HEAD', revisions[0].message
		end

		# A file is created and modified on the branch, then merged to the trunk, then deleted from the branch.
		# From the branch's point of view, we should see the add, modify, and delete only.
		def test_file_created_on_branch_as_seen_from_branch
			revisions = CvsParser.parse File.read(DATA_DIR + '/file_created_on_branch.rlog'), :branch_name => 'my_branch'
			assert_equal 3, revisions.size
			assert_equal 'added new_file.rb on the branch', revisions[0].message
			assert_equal 'modifed new_file.rb on the branch only', revisions[1].message
			assert_equal 'removed new_file.rb from the branch only', revisions[2].message
		end

		# A file is created on the vender branch. This causes a simultaneous checkin on HEAD
		# with a different message ('Initial revision') but same committer_name name and timestamp.
		# We should only pick up one of these checkins.
		def test_simultaneous_checkins
			revisions = CvsParser.parse File.read(DATA_DIR + '/simultaneous_checkins.rlog')
			assert_equal 1, revisions.size
			assert_equal 'Initial revision', revisions[0].message
		end

		# Two different authors check in with two different messages at the exact same moment.
		# How this happens is a mystery, but I have seen it in rlogs.
		# We arbitrarily choose the first one if so.
		def test_simultaneous_checkins_2
			revisions = CvsParser.parse File.read(DATA_DIR + '/simultaneous_checkins_2.rlog')
			assert_equal 1, revisions.size
		end
	end
end
