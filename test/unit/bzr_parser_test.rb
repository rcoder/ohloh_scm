require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class BzrParserTest < Scm::Test

		def test_empty_array
			assert_equal([], BzrParser.parse(''))
		end

		def test_default_log_parser
sample_log = <<SAMPLE
------------------------------------------------------------
revno: 2
committer: Robin <robin@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:49:42 +0100
message:
  Second Revision
------------------------------------------------------------
revno: 1
committer: Jason <jason@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:25:40 +0100
message:
  Initial Revision
SAMPLE

			commits = BzrParser.parse(sample_log)

			assert commits
			assert_equal 2, commits.size

			assert_equal '2', commits[0].token
			assert_equal 'Robin', commits[0].committer_name
			assert_equal 'robin@ohloh.net', commits[0].committer_email
			assert_equal "Second Revision\n", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,49,42), commits[0].committer_date
			assert_equal 0, commits[0].diffs.size

			assert_equal '1', commits[1].token
			assert_equal 'Jason', commits[1].committer_name
			assert_equal 'jason@ohloh.net', commits[1].committer_email
			assert_equal "Initial Revision\n", commits[1].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,25,40), commits[1].committer_date
			assert_equal 0, commits[1].diffs.size
		end

		def test_verbose_log_parser
sample_log = <<SAMPLE
------------------------------------------------------------
revno: 2
committer: Robin <robin@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:49:42 +0100
message:
  Second Revision
removed:
  file1.txt
modified:
  file2.txt
------------------------------------------------------------
revno: 1
committer: Jason <jason@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:25:40 +0100
message:
  Initial Revision
added:
  file1.txt
  file2.txt
SAMPLE

			commits = BzrParser.parse(sample_log)

			assert commits
			assert_equal 2, commits.size

			assert_equal '2', commits[0].token
			assert_equal 'Robin', commits[0].committer_name
			assert_equal 'robin@ohloh.net', commits[0].committer_email
			assert_equal "Second Revision\n", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,49,42), commits[0].committer_date
			assert_equal 2, commits[0].diffs.size

			assert_equal 'file1.txt', commits[0].diffs[0].path
			assert_equal 'D', commits[0].diffs[0].action
			assert_equal 'file2.txt', commits[0].diffs[1].path
			assert_equal 'M', commits[0].diffs[1].action

			assert_equal '1', commits[1].token
			assert_equal 'Jason', commits[1].committer_name
			assert_equal 'jason@ohloh.net', commits[1].committer_email
			assert_equal "Initial Revision\n", commits[1].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,25,40), commits[1].committer_date
			assert_equal 2, commits[1].diffs.size

			assert_equal 'file1.txt', commits[1].diffs[0].path
			assert_equal 'A', commits[1].diffs[0].action
			assert_equal 'file2.txt', commits[1].diffs[1].path
			assert_equal 'A', commits[1].diffs[1].action
		end

		def test_verbose_log_parser_with_show_id
sample_log = <<SAMPLE
------------------------------------------------------------
revno: 2
revision-id: info@ohloh.net-20090204004942-73rnw0izen42f154
parent: info@ohloh.net-20090204002540-gmana8tk5f9gboq9
committer: Robin <robin@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:49:42 +0100
message:
  Second Revision
removed:
  file1.txt                      file1.txt-20090204002338-awfasrgh9nuzc53d-1
modified:
  file2.txt                      file2.txt-20090204002419-s025jc9k05dghk6d-1
------------------------------------------------------------
revno: 1
revision-id: info@ohloh.net-20090204002540-gmana8tk5f9gboq9
parent: info@ohloh.net-20090204002518-yb0x153oa6mhoodu
committer: Jason <jason@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:25:40 +0100
message:
  Initial Revision
added:
  file1.txt                      file1.txt-20090204002338-awfasrgh9nuzc53d-1
  file2.txt                      file2.txt-20090204002419-s025jc9k05dghk6d-1
SAMPLE

			commits = BzrParser.parse(sample_log)

			assert commits
			assert_equal 2, commits.size

			assert_equal 'info@ohloh.net-20090204004942-73rnw0izen42f154', commits[0].token
			assert_equal 'Robin', commits[0].committer_name
			assert_equal 'robin@ohloh.net', commits[0].committer_email
			assert_equal "Second Revision\n", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,49,42), commits[0].committer_date
			assert_equal 2, commits[0].diffs.size

			assert_equal 'file1.txt', commits[0].diffs[0].path
			assert_equal 'D', commits[0].diffs[0].action
			assert_equal 'file2.txt', commits[0].diffs[1].path
			assert_equal 'M', commits[0].diffs[1].action

			assert_equal 'info@ohloh.net-20090204002540-gmana8tk5f9gboq9', commits[1].token
			assert_equal 'Jason', commits[1].committer_name
			assert_equal 'jason@ohloh.net', commits[1].committer_email
			assert_equal "Initial Revision\n", commits[1].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,25,40), commits[1].committer_date
			assert_equal 2, commits[1].diffs.size

			assert_equal 'file1.txt', commits[1].diffs[0].path
			assert_equal 'A', commits[1].diffs[0].action
			assert_equal 'file2.txt', commits[1].diffs[1].path
			assert_equal 'A', commits[1].diffs[1].action
		end

		def test_verbose_log_parser_very_long_filename_with_show_id
sample_log = <<SAMPLE
------------------------------------------------------------
revno: 1
revision-id: info@ohloh.net-20090204002540-gmana8tk5f9gboq9
parent: info@ohloh.net-20090204002518-yb0x153oa6mhoodu
committer: Jason <jason@ohloh.net>
branch nick: bzr
timestamp: Wed 2009-02-04 01:25:40 +0100
message:
  Initial Revision
added:
  a very long filename with space intended to cause log parsing problems averylongfilenamewit-20090205232320-4fl43j6djs9pfnn4-1
SAMPLE

			commits = BzrParser.parse(sample_log)

			assert commits
			assert_equal 1, commits.size

			assert_equal 'info@ohloh.net-20090204002540-gmana8tk5f9gboq9', commits[0].token
			assert_equal 'Jason', commits[0].committer_name
			assert_equal 'jason@ohloh.net', commits[0].committer_email
			assert_equal "Initial Revision\n", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,2,4,0,25,40), commits[0].committer_date

			assert_equal 1, commits[0].diffs.size
			assert_equal 'a very long filename with space intended to cause log parsing problems', commits[0].diffs[0].path
			assert_equal 'A', commits[0].diffs[0].action
		end
	end
end
