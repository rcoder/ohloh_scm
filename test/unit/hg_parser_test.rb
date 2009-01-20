require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class HgParserTest < Scm::Test

		def test_empty_array
			assert_equal([], HgParser.parse(''))
		end

		def test_log_parser_default
sample_log = <<SAMPLE
changeset:   1:b14fa4692f94
user:        Jason Allen <jason@ohloh.net>
date:        Tue Jan 20 11:33:17 2009 -0800
summary:     added makefile


changeset:   0:01101d8ef3ce
user:        Robin Luckey <robin@ohloh.net>
date:        Tue Jan 20 11:32:54 2009 -0800
summary:     Initial Checkin

SAMPLE

			commits = HgParser.parse(sample_log)

			assert commits
			assert_equal 2, commits.size

			assert_equal 'b14fa4692f94', commits[0].token
			assert_equal 'Jason Allen', commits[0].committer_name
			assert_equal 'jason@ohloh.net', commits[0].committer_email
			assert_equal "added makefile", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,1,20,19,33,17), commits[0].committer_date
			assert_equal 0, commits[0].diffs.size

			assert_equal '01101d8ef3ce', commits[1].token
			assert_equal 'Robin Luckey', commits[1].committer_name
			assert_equal 'robin@ohloh.net', commits[1].committer_email
			assert_equal "Initial Checkin", commits[1].message # Note \n at end of comment
			assert_equal Time.utc(2009,1,20,19,32,54), commits[1].committer_date
			assert_equal 0, commits[1].diffs.size
		end

		def test_log_parser_verbose
sample_log = <<SAMPLE
changeset:   1:b14fa4692f94
user:        Jason Allen <jason@ohloh.net>
date:        Tue Jan 20 11:33:17 2009 -0800
files:       makefile
description:
added makefile


changeset:   0:01101d8ef3ce
user:        Robin Luckey <robin@ohloh.net>
date:        Tue Jan 20 11:32:54 2009 -0800
files:       helloworld.c
description:
Initial Checkin


SAMPLE

			commits = HgParser.parse(sample_log)

			assert commits
			assert_equal 2, commits.size

			assert_equal 'b14fa4692f94', commits[0].token
			assert_equal 'Jason Allen', commits[0].committer_name
			assert_equal 'jason@ohloh.net', commits[0].committer_email
			assert_equal "added makefile\n", commits[0].message # Note \n at end of comment
			assert_equal Time.utc(2009,1,20,19,33,17), commits[0].committer_date
			assert_equal 1, commits[0].diffs.size
			assert_equal 'makefile', commits[0].diffs[0].path

			assert_equal '01101d8ef3ce', commits[1].token
			assert_equal 'Robin Luckey', commits[1].committer_name
			assert_equal 'robin@ohloh.net', commits[1].committer_email
			assert_equal "Initial Checkin\n", commits[1].message # Note \n at end of comment
			assert_equal Time.utc(2009,1,20,19,32,54), commits[1].committer_date
			assert_equal 1, commits[1].diffs.size
			assert_equal 'helloworld.c', commits[1].diffs[0].path
		end
	end
end
