require 'spec_helper'

describe 'BzrLibActivity' do
  it 'must return head and parents correctly' do
    with_bzr_lib_repository('bzr') do |bzr|
      activity = bzr.activity

      activity.head_token.must_equal 'test@example.com-20111222183733-y91if5npo3pe8ifs'
      activity.head.token.must_equal 'test@example.com-20111222183733-y91if5npo3pe8ifs'
      assert activity.head.diffs.any? # diffs should be populated

      activity.parents(activity.head).first.token.must_equal 'obnox@samba.org-20090204004942-73rnw0izen42f154'
      assert activity.parents(activity.head).first.diffs.any?
    end
  end

  describe 'cat_file' do
    it 'must return file contents' do
      with_bzr_lib_repository('bzr') do |bzr|
        expected = <<-EXPECTED.gsub(/^ {10}/, '')
          first file
          second line
        EXPECTED

        commit = OhlohScm::Commit.new(token: 6)
        diff = OhlohScm::Diff.new(path: 'file1.txt')
        bzr.activity.cat_file(commit, diff).must_equal expected

        # file2.txt has been removed in commit #5
        diff2 = OhlohScm::Diff.new(path: 'file2.txt')
        bzr.activity.cat_file(bzr.activity.head, diff2).must_be_nil
      end
    end

    it 'must handle content with non ascii chars' do
      with_bzr_lib_repository('bzr') do |bzr|
        expected = <<-EXPECTED.gsub(/^ {10}/, '')
          first file
          second line
        EXPECTED

        commit = OhlohScm::Commit.new(token: 7)
        diff = OhlohScm::Diff.new(path: 'Cédric.txt')
        bzr.activity.cat_file(commit, diff).must_equal expected
      end
    end

    it 'must get file contents by parent rev' do
      with_bzr_lib_repository('bzr') do |bzr|
        expected = <<-EXPECTED.gsub(/^ {10}/, '')
          first file
          second line
        EXPECTED

        commit = OhlohScm::Commit.new(token: 6)
        diff = OhlohScm::Diff.new(path: 'file1.txt')
        bzr.activity.cat_file_parent(commit, diff).must_equal expected

        # file2.txt has been removed in commit #5
        expected = <<-EXPECTED.gsub(/^ {10}/, '')
          another file
        EXPECTED
        commit2 = OhlohScm::Commit.new(token: 5)
        diff2 = OhlohScm::Diff.new(path: 'file2.txt')
        bzr.activity.cat_file_parent(commit2, diff2).must_equal expected
      end
    end
  end
end
