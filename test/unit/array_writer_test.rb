require_relative '../test_helper'

module OhlohScm::Parsers
	class ArrayWriterTest < OhlohScm::Test

		def test_basic

			log = <<-LOG
------------------------------------------------------------------------
r3 | robin | 2006-06-11 11:34:17 -0700 (Sun, 11 Jun 2006) | 1 line
Changed paths:
   A /trunk/README
   M /trunk/helloworld.c

added some documentation and licensing info
------------------------------------------------------------------------
			LOG

			# By default, the ArrayWriter is used, and an empty string is parsed
			assert_equal [], SvnParser.parse
			assert_equal [], SvnParser.parse('')
			assert_equal [], SvnParser.parse('', :writer => ArrayWriter.new)

			result = SvnParser.parse(log, :writer => ArrayWriter.new)
			assert_equal 1, result.size
			assert_equal 'robin', result.first.committer_name
			assert_equal 3, result.first.token
			assert_equal 2, result.first.diffs.size
			assert_equal '/trunk/README', result.first.diffs.first.path
			assert_equal 'A', result.first.diffs.first.action
		end
	end
end
