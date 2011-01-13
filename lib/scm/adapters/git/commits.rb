module Scm::Adapters
	class GitAdapter < AbstractAdapter

		# Returns the number of commits in the repository following the commit with SHA1 'since'.
		def commit_count(opts={})
			run("#{rev_list_command(opts)} | wc -l").to_i
		end

		# Returns the SHA1 hash for every commit in the repository following the commit with SHA1 'since'.
		def commit_tokens(opts={})
			run(rev_list_command(opts)).split("\n")
		end

		# Yields each commit following the commit with SHA1 'since'.
		# Officially, this method isn't required to provide diffs with these commits,
    # and the Subversion equivalent of this method does not,
		# so if you really require the diffs you should be using each_commit() instead.
		def commits(opts={})
			result = []
			each_commit(opts) { |c| result << c }
			result
		end

		# Yields each commit in the repository following the commit with SHA1 'since'.
		# These commits are populated with diffs.
		def each_commit(opts={})

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
			# vs. the first parent only, and diffs vs. other parents are lost. For Ohloh, this is fine
			# because Ohloh ignores merge diffs anyway.

			previous = nil
			Scm::Parsers::GitStyledParser.parse(log(opts)) do |e|
				yield e unless previous && previous.token == e.token
				previous = e
			end
		end

		# Returns a single commit, including its diffs
		def verbose_commit(token)
			Scm::Parsers::GitStyledParser.parse(run("cd '#{url}' && #{Scm::Parsers::GitStyledParser.whatchanged} #{token}")).first
		end

		# Retrieves the git log in the format expected by GitStyledParser.
		# We get the log forward chronological order (oldest first)
		def log(opts={})
			if has_branch?
				if opts[:since] && opts[:since]==self.head_token
					'' # Nothing new.
				else
					run "#{rev_list_command(opts)} | xargs -n 1 #{Scm::Parsers::GitStyledParser.whatchanged}"
				end
			else
				''
			end
		end

		def rev_list_command(opts={})
      up_to = opts[:up_to] || branch_name
			range = opts[:since] ? "#{opts[:since]}..#{up_to}" : up_to

      trunk_only = opts[:trunk_only] ? "--first-parent" : ""

			"cd '#{url}' && git rev-list --topo-order --reverse #{trunk_only} #{range}"
		end
	end
end
