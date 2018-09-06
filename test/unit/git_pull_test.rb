require_relative '../test_helper'

module OhlohScm::Adapters
	class GitPullTest < OhlohScm::Test

		def test_basic_pull
			with_git_repository('git') do |src|
				OhlohScm::ScratchDir.new do |dest_dir|

					dest = GitAdapter.new(:url => dest_dir).normalize
					assert !dest.exist?

					dest.pull(src)
					assert dest.exist?

					assert_equal src.log, dest.log
				end
			end
		end

    def test_basic_pull_with_exception
      with_svn_repository('svn_empty') do |src|
        OhlohScm::ScratchDir.new do |dest_dir|
          dest = GitAdapter.new(:url => dest_dir).normalize
          assert !dest.exist?
          err = assert_raises(RuntimeError) { dest.pull(src) }
          assert_match /Empty repository/, err.message
        end
      end
    end

    def test_basic_pull_of_non_default_branch
      # This should not change current/default branch(e.g. master) to point to the branch commit being pulled
      # In this case master should not point to test branch commit
      with_git_repository('git_with_multiple_branch', 'test') do |src|
	OhlohScm::ScratchDir.new do |dest_dir|
          dest = GitAdapter.new(:url => dest_dir, branch_name: 'test').normalize
	  assert !dest.exist?
	  dest.pull(src)
          remote_master_branch_sha =  `cd #{dest_dir}  && git rev-parse origin/master`
          master_branch_sha = `cd #{dest_dir}  && git rev-parse master`
          test_branch_sha = `cd #{dest_dir}  && git rev-parse test`

          assert_not_equal master_branch_sha, test_branch_sha 
          assert_equal master_branch_sha, remote_master_branch_sha
	end
      end
    end
        end
end
