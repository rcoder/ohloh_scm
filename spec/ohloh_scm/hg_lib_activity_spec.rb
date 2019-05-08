require 'spec_helper'

describe 'HgLibActivity' do
  describe 'cat_file' do
    it 'must get file contents by current or parent commit' do
      with_hg_lib_repository('hg') do |hg_lib|
        expected = <<-EXPECTED.gsub(/^ {10}/, '')
          /* Hello, World! */

          /*
           * This file is not covered by any license, especially not
           * the GNU General Public License (GPL). Have fun!
           */

          #include <stdio.h>
          main()
          {
          	printf("Hello, World!\\n");
          }
        EXPECTED

        diff = OhlohScm::Diff.new(path: 'helloworld.c')
        commit = OhlohScm::Commit.new(token: '75532c1e1f1d')
        # The file was deleted in revision 468336c6671c. Check that it does not exist now, but existed in parent.
        hg_lib.activity.cat_file(commit, diff).must_be_nil
        hg_lib.activity.cat_file_parent(commit, diff).must_equal expected
        hg_lib.activity.cat_file(OhlohScm::Commit.new(token: '468336c6671c'), diff).must_equal expected
      end
    end

    # Ensure that we escape bash-significant characters like ' and & when they appear in the filename
    it 'must handle funny file names' do
      tmpdir do |dir|
        # Make a file with a problematic filename
        funny_name = '#|file_name` $(&\'")#'
        content = 'contents'
        File.open("#{dir}/#{funny_name}", 'w') { |f| f.write(content) }

        # Add it to an hg repository
        `cd #{dir} && hg init && hg add * 2> /dev/null && hg commit -u tester -m test`

        # Confirm that we can read the file back
        hg_lib = OhlohScm::Factory.get_base(scm_type: :hg_lib, url: dir)
        diff = OhlohScm::Diff.new(path: funny_name)
        hg_lib.activity.cat_file(hg_lib.activity.head, diff).must_equal content
      end
    end
  end
end
