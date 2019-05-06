require 'spec_helper'

describe 'GitScm' do
  it 'must pull git repository' do
    with_git_repository('git') do |src_base|
      tmpdir do |dest_dir|
        base = OhlohScm::Factory.get_base(scm_type: :git, url: dest_dir)
        refute base.status.exist?

        base.scm.pull(src_base.scm, TestCallback.new)
        assert base.status.exist?
      end
    end
  end

  it 'must pull git repository with multiple branches' do
    # This should not change current/default branch(e.g. master) to point to the branch commit being pulled
    # In this case master should not point to test branch commit
    with_git_repository('git_with_multiple_branch', 'test') do |src_base|
      tmpdir do |dest_dir|
        base = OhlohScm::Factory.get_base(scm_type: :git, url: dest_dir, branch_name: 'test')
        refute base.status.exist?
        base.scm.pull(src_base.scm, TestCallback.new)

        remote_master_branch_sha = `cd #{dest_dir} && git rev-parse origin/master`
        master_branch_sha = `cd #{dest_dir} && git rev-parse master`
        test_branch_sha = `cd #{dest_dir} && git rev-parse test`

        master_branch_sha.wont_equal test_branch_sha
        master_branch_sha.must_equal remote_master_branch_sha
      end
    end
  end
end
