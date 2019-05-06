# frozen_string_literal: true

module OhlohScm
  class GitScm < Scm
    def initialize(base:, url:, branch_name:, username:, password:)
      super
      @branch_name = branch_name || 'master'
    end

    # == Example:
    #   remote_base = OhlohScm::Factory.get_base(url: 'https://github.com/ruby/ruby')
    #   local_base = OhlohScm::Factory.get_base(url: '/tmp/ruby-src')
    #   local_base.scm.pull(remote_base.scm)
    def pull(from, callback)
      clone_or_fetch(from, callback)
    end

    def vcs_path
      "#{url}/.git"
    end

    private

    def clone_or_fetch(remote_scm, callback)
      callback.update(0, 1)
      if status.branch?(branch_name)
        clean_and_checkout_branch # should already be on correct branch, but we want to be careful.
        fetch_new_commits(remote_scm)
      else
        clone_and_create_tracking_branch(remote_scm)
      end
      clean_up_disk
      callback.update(1, 1)
    end

    def fetch_new_commits(remote_scm)
      run "cd '#{url}' && git fetch --tags --update-head-ok \
            '#{remote_scm.url}' #{branch_name}:#{branch_name}"
    end

    def clone_and_create_tracking_branch(remote_scm)
      run "rm -rf '#{url}'"
      run "git clone -q -n '#{remote_scm.url}' '#{url}'"
      create_tracking_branch(remote_scm.branch_name) # ensure the correct branch exists locally
      clean_and_checkout_branch # switch to the correct branch
    end

    # We need very high reliability and this sequence gets the job done every time.
    def clean_and_checkout_branch
      return unless status.scm_dir_exist?

      run "cd '#{url}' && git clean -f -d -x"
      return unless status.branch?(branch_name)

      run "cd '#{url}' && git checkout #{branch_name} --"
      run "cd '#{url}' && git reset --hard heads/#{branch_name} --"
    end

    def create_tracking_branch(branch_name)
      return if branch_name.to_s.empty?
      return if activity.branches.include?(branch_name)

      run "cd '#{url}' && git branch -f #{branch_name} origin/#{branch_name}"
    end

    # Deletes everything but the *.git* folder in the working directory.
    def clean_up_disk
      return unless Dir.exist?(url)

      run "cd #{url} && find . -maxdepth 1 -not -name .git -not -name . \
        -print0 | xargs -0 rm -rf --"
    end
  end
end
