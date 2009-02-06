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

		def test_verbose_log_with_nested_merge_commits
sample_log = <<SAMPLE
------------------------------------------------------------
revno: 16
revision-id: robin@ohloh.net-20080629125019-qxk9qma8esphwwus
parent: robin@ohloh.net-20080629121849-2le5txjj7tkdq54f
parent: robin@ohloh.net-20080630050459-ox7a50k5qi6tg2z2
committer: robin <robin@ohloh.net>
branch nick: ohloh
timestamp: Sun 2008-06-29 05:50:19 -0700
message:
  Committing merge
removed:
  goodbye_world.c                goodbye_world.c-20080625052902-61bbthtf22shh0p6-293
    ------------------------------------------------------------
    revno: 12.1.2
    revision-id: robin@ohloh.net-20080629214643-5ru67mh04j09cmiz
    parent: robin@ohloh.net-20080629201028-923bdzz0qcjmd6cm
    committer: robin <robin@ohloh.net>
    branch nick: ohloh
    timestamp: Sun 2008-06-29 14:46:43 -0700
    message:
      Second commit on branch
    modified:
      hello_world.c                  hello_world.c-20080625052902-61bbthtf22shh0p6-447
    ------------------------------------------------------------
    revno: 12.1.1
    revision-id: robin@ohloh.net-20080629201028-923bdzz0qcjmd6cm
    parent: robin@ohloh.net-20080629191920-ioqljg6ihntzcz9y
    committer: robin <robin@ohloh.net>
    branch nick: ohloh
    timestamp: Sun 2008-06-29 13:10:28 -0700
    message:
      First commit on branch
    added:
      goodbye_world.c                goodbye_world.c-20080625052902-61bbthtf22shh0p6-422
------------------------------------------------------------
revno: 15
revision-id: robin@ohloh.net-20080629121849-2le5txjj7tkdq54f
parent: robin@ohloh.net-20080629092342-7jfxn10e2qchi931
committer: robin <robin@ohloh.net>
branch nick: ohloh
timestamp: Sun 2008-06-29 05:18:49 -0700
message:
  First commit on trunk
modified:
  hello_world.c                  hello_world.c-20080625052902-61bbthtf22shh0p6-293
SAMPLE
			commits = BzrParser.parse(sample_log)

			assert commits
			assert_equal 4, commits.size

			assert_equal 'robin@ohloh.net-20080629125019-qxk9qma8esphwwus', commits[0].token
			assert_equal 'robin@ohloh.net-20080629214643-5ru67mh04j09cmiz', commits[1].token
			assert_equal 'robin@ohloh.net-20080629201028-923bdzz0qcjmd6cm', commits[2].token
			assert_equal 'robin@ohloh.net-20080629121849-2le5txjj7tkdq54f', commits[3].token

			assert_equal 1, commits[0].diffs.size
			assert_equal 'goodbye_world.c', commits[0].diffs[0].path
			assert_equal 'D', commits[0].diffs[0].action

			assert_equal 1, commits[1].diffs.size
			assert_equal 'hello_world.c', commits[1].diffs[0].path
			assert_equal 'M', commits[1].diffs[0].action

			assert_equal 1, commits[2].diffs.size
			assert_equal 'goodbye_world.c', commits[2].diffs[0].path
			assert_equal 'A', commits[2].diffs[0].action

			assert_equal 1, commits[3].diffs.size
			assert_equal 'hello_world.c', commits[3].diffs[0].path
			assert_equal 'M', commits[3].diffs[0].action
		end
	end
end
