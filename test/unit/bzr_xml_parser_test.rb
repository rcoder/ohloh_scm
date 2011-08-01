require File.dirname(__FILE__) + '/../test_helper'

module Scm::Parsers
	class BzrXmlParserTest < Scm::Test

		#def test_basic
		#	assert_convert(BzrXmlParser, DATA_DIR + '/simple.svn_xml_log', DATA_DIR + '/simple.ohlog')
		#end

		def test_empty_array
			assert_equal([], BzrXmlParser.parse(''))
		end

		def test_empty_xml
			assert_equal("<?xml version=\"1.0\"?>\n<ohloh_log scm=\"bzr\">\n</ohloh_log>\n", BzrXmlParser.parse('', :writer => XmlWriter.new))
		end
		
		def test_basic_xml
      xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<logs>
  <log>
    <revno>10</revno>
    <revisionid>test@example.com-20110725174345-brbpkwumeh07aoh8</revisionid>
    <parents>
      <parent>amujumdar@blackducksoftware.com-20110722185038-e0i4d1mdxwpipxc4</parent>
    </parents>
    <committer>test &lt;test@example.com&gt;</committer>
    <branch-nick>myproject</branch-nick>
    <timestamp>Mon 2011-07-25 13:43:45 -0400</timestamp>
    <message><![CDATA[Renamed test1.txt to subdir/test_b.txt, removed test2.txt and added test_a.txt.]]></message>
    <affected-files>
      <removed>
        <file fid="test2.txt-20110722163813-257mjqqrvw3mav0f-3">test2.txt</file>
      </removed>
      <added>
        <file fid="test_a.txt-20110725174250-y989xbb6y8ae027k-1">test_a.txt</file>
      </added>
      <renamed>
        <file oldpath="test1.txt" fid="test1.txt-20110722163813-257mjqqrvw3mav0f-2">subdir/test_b.txt</file>
      </renamed>
    </affected-files>
  </log>
</logs>
      XML
			commits = BzrXmlParser.parse(xml)
			assert_equal 1, commits.size
      c = commits.first
			assert_equal 4, c.diffs.size # Rename is a D followed by A

			assert_equal "test2.txt", c.diffs[0].path
      assert_equal "D", c.diffs[0].action
			
			assert_equal "test_a.txt", c.diffs[1].path
      assert_equal "A", c.diffs[1].action

			assert_equal "test1.txt", c.diffs[2].path
      assert_equal "D", c.diffs[2].action

			assert_equal "subdir/test_b.txt", c.diffs[3].path
      assert_equal "A", c.diffs[3].action
		end

	end
end
