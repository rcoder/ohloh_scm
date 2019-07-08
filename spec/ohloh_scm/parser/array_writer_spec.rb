require 'spec_helper'

describe 'ArrayWriter' do
  it 'must work' do
    log = <<-LOG.gsub(/^ {6}/, '')
      __BEGIN_COMMIT__
      Commit: 1df547800dcd168e589bb9b26b4039bff3a7f7e4
      Author: Jason Allen
      AuthorEmail: jason@ohloh.net
      Date:   Fri, 14 Jul 2006 16:07:15 -0700
      __BEGIN_COMMENT__
      moving COPYING

      __END_COMMENT__

      :000000 100755 0000000000000000000000000000000000000000 a7b13ff050aed1191c45d7a5db9a50edcdc5755f A	COPYING
    LOG

    commits = OhlohScm::GitParser.parse(log)
    commits.size.must_equal 1
    commit = commits.first
    commit.token.must_equal '1df547800dcd168e589bb9b26b4039bff3a7f7e4'
    commit.author_name.must_equal 'Jason Allen'
    commit.author_email.must_equal 'jason@ohloh.net'
    commit.message.must_equal "moving COPYING\n"
    commit.author_date.must_equal Time.utc(2006, 7, 14, 23, 7, 15)
    commit.diffs.size.must_equal 1
  end
end
