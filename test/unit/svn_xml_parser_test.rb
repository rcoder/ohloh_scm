require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class SvnXmlParserTest < Scm::Test

		def test_basic
			assert_convert(SvnXmlParser, DATA_DIR + '/simple.svn_xml_log', DATA_DIR + '/simple.ohlog')
		end

		def test_empty_array
			assert_equal([], SvnXmlParser.parse(''))
		end

		def test_empty_xml
			assert_equal("<?xml version=\"1.0\"?>\n<ohloh_log scm=\"svn\">\n</ohloh_log>\n", SvnXmlParser.parse('', :writer => XmlWriter.new))
		end

	end
end
