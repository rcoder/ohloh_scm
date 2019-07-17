require 'spec_helper'

describe 'Git::Scm' do
  it 'must pull git repository' do
    with_git_repository('git') do |src_core|
      tmpdir do |dest_dir|
        core = OhlohScm::Factory.get_core(scm_type: :git, url: dest_dir)
        refute core.status.scm_dir_exist?

        core.scm.pull(src_core.scm, TestCallback.new)
        assert core.status.scm_dir_exist?
        assert core.status.exist?
      end
    end
  end

  it 'must pull git repository with multiple branches' do
    # This should not change current/default branch(e.g. master) to point to the branch commit being pulled
    # In this case master should not point to test branch commit
    with_git_repository('git_with_multiple_branch', 'test') do |src_core|
      tmpdir do |dest_dir|
        core = OhlohScm::Factory.get_core(scm_type: :git, url: dest_dir, branch_name: 'test')
        refute core.status.scm_dir_exist?
        core.scm.pull(src_core.scm, TestCallback.new)

        remote_master_branch_sha = `cd #{dest_dir} && git rev-parse origin/master`
        master_branch_sha = `cd #{dest_dir} && git rev-parse master`
        test_branch_sha = `cd #{dest_dir} && git rev-parse test`

        master_branch_sha.wont_equal test_branch_sha
        master_branch_sha.must_equal remote_master_branch_sha
      end
    end
  end

  it 'must test the basic conversion to git' do
    with_cvs_repository('cvs', 'simple') do |src_core|
      tmpdir do |dest_dir|
        core = OhlohScm::Factory.get_core(scm_type: :git, url: dest_dir)
        refute core.status.scm_dir_exist?
        core.scm.pull(src_core.scm, TestCallback.new)
        assert core.status.scm_dir_exist?
        assert core.status.exist?

        dest_commits = core.activity.commits
        src_core.activity.commits.each_with_index do |c, i|
          # Because CVS does not track authors (only committers),
          # the CVS committer becomes the Git author.
          c.committer_date.must_equal dest_commits[i].author_date
          c.committer_name.must_equal dest_commits[i].author_name

          # Depending upon version of Git used, we may or may not have a trailing \n.
          # We don't really care, so just compare the stripped versions.
          c.message.strip.must_equal dest_commits[i].message.strip
        end
      end
    end
  end
end
