# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module OhlohScm
  class GitActivity < Activity
    def_delegators :scm, :url

    NULL_SHA1 = '0000000000000000000000000000000000000000'

    def tags
      return [] if no_tags?

      flags = "--format='%(creatordate:iso-strict) %(objectname) %(refname)'"
      tag_strings = run("cd #{url} && git tag #{flags} | sed 's/refs\\/tags\\///'").split(/\n/)
      tag_strings.map do |tag_string|
        timestamp_string, commit_hash, tag_name = tag_string.split(/\s/)
        [tag_name, dereferenced_sha(tag_name) || commit_hash, time_object(timestamp_string)]
      end
    end

    def export(dest_dir, commit_id = 'HEAD')
      run "cd #{url} && git archive #{commit_id} | tar -C #{dest_dir} -x"
    end

    # Returns the number of commits in the repository following the commit with SHA1 'after'.
    def commit_count(opts = {})
      run("#{rev_list_command(opts)} | wc -l").to_i
    end

    def commit_tokens(opts = {})
      run(rev_list_command(opts)).split("\n")
    end

    # Yields each commit following the commit with SHA1 'after'.
    # Officially, this method isn't required to provide diffs with these commits,
    # and the Subversion equivalent of this method does not,
    # so if you really require the diffs you should be using each_commit() instead.
    def commits(opts = {})
      result = []
      each_commit(opts) { |c| result << c }
      result
    end

    # Yields each commit in the repository following the commit with SHA1 'after'.
    # These commits are populated with diffs.
    def each_commit(opts = {})
      # Bug fix (hack) follows.
      #
      # git-whatchanged emits a merge commit multiple times, once for each parent, giving the
      # delta to each parent in turn.
      #
      # This causes us to emit too many commits, with repeated merge commits.
      #
      # To fix this, we track the previous commit, and emit a new commit only if it is distinct
      # from the previous.
      #
      # This means that the diffs for a merge commit yielded by this method will be the diffs
      # vs. the first parent only, and diffs vs. other parents are lost. For OpenHub, this is fine
      # because OpenHub ignores merge diffs anyway.
      previous = nil
      safe_open_log_file(opts) do |io|
        OhlohScm::GitParser.parse(io) do |e|
          yield fixup_null_merge(e) unless previous && previous.token == e.token
          previous = e
        end
      end
    end

    # Returns a single commit, including its diffs
    def verbose_commit(token)
      cmd = "cd '#{url}' && #{OhlohScm::GitParser.whatchanged} #{token}"\
            " | #{string_encoder_path}"
      commit = OhlohScm::GitParser.parse(run(cmd)).first
      fixup_null_merge(commit)
    end

    # For a merge commit, we ask `git whatchanged` to output the changes relative to each parent.
    # It is possible, through dev hackery, to create a merge commit which does not change the tree.
    # When this happens, `git whatchanged` will suppress its output relative to the first parent,
    # and jump immediately to the second (branch) parent. Our code mistakenly interprets this
    # output as the missing changes relative to the first parent.
    #
    # To avoid this calamity, we must compare the tree hash of this commit with its first parent's.
    # If they are equal, then the diff should be empty, regardless of what `git whatchanged` says.
    #
    # Yes, this is a convoluted, time-wasting hack to address a very rare circumstance. Ultimatley
    # we should stop parsing `git whatchanged` to extract commit data.
    def fixup_null_merge(commit)
      first_parent_token = parent_tokens(commit).first
      if first_parent_token && get_commit_tree(first_parent_token) == get_commit_tree(commit.token)
        commit.diffs = []
      end
      commit
    end

    def head_token
      run("git ls-remote --heads '#{url}' #{scm.branch_name}") =~ /^(^[a-z0-9]{40})\s+\S+$/
      Regexp.last_match(1)
    end

    def head
      verbose_commit(head_token)
    end

    def cat_file(_commit, diff)
      cat(diff.sha1)
    end

    def cat_file_parent(_commit, diff)
      cat(diff.parent_sha1)
    end

    def branches
      cmd = "cd '#{url}' && git branch | #{string_encoder_path}"
      run(cmd).split.select { |branch_name| branch_name =~ /\b(.+)$/ }
    end

    private

    def cat(sha1)
      return '' if sha1 == NULL_SHA1

      run "cd '#{url}' && git cat-file -p #{sha1}"
    end

    def parent_tokens(commit)
      run("cd '#{url}' && git cat-file commit #{commit.token} | grep ^parent | cut -f 2 -d ' '")
        .split("\n")
    end

    # For a given commit ID, returns the SHA1 hash of its tree
    def get_commit_tree(token = 'HEAD')
      run("cd #{url} && git cat-file commit #{token} | grep '^tree' | cut -d ' ' -f 2").strip
    end

    def safe_open_log_file(opts = {})
      return '' unless status.branch?
      return '' if opts[:after] && opts[:after] == head_token

      open_log_file(opts) { |io| yield io }
    end

    def open_log_file(opts)
      run "#{rev_list_command(opts)} | xargs -n 1 #{OhlohScm::GitParser.whatchanged}"\
            " | #{string_encoder_path} > #{log_filename}"
      File.open(log_filename, 'r') { |io| yield io }
    ensure
      File.delete(log_filename) if File.exist?(log_filename)
    end

    def rev_list_command(opts = {})
      up_to = opts[:up_to] || "heads/#{scm.branch_name}"
      range = opts[:after] ? "#{opts[:after]}..#{up_to}" : up_to

      trunk_only = opts[:trunk_only] ? '--first-parent' : ''
      "cd '#{url}' && git rev-list --topo-order --reverse #{trunk_only} #{range}"
    end

    def dereferenced_sha(tag_name)
      dtag_sha_and_name = dtag_sha_and_names.find { |sha_and_name| sha_and_name.last == tag_name }
      dtag_sha_and_name&.first
    end

    def dtag_sha_and_names
      @dtag_sha_and_names ||= dereferenced_tag_strings.map(&:split)
    end

    def dereferenced_tag_strings
      # Pattern: b6e9220c3cabe53a4ed7f32952aeaeb8a822603d refs/tags/v1.0.0^{}
      run("cd #{url} && git show-ref --tags -d | grep '\\^{}' | sed 's/\\^{}//'"\
            " | sed 's/refs\\/tags\\///'").split(/\n/)
    end

    def time_object(timestamp_string)
      timestamp_string = '1970-01-01' if timestamp_string.strip.empty?
      Time.parse(timestamp_string)
    end

    def no_tags?
      run("cd #{url} && git tag | head -1").empty?
    end
  end
end
# rubocop:enable Metrics/ClassLength
