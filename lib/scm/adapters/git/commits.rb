module Scm::Adapters
	class GitAdapter < AbstractAdapter

		# Returns the number of commits in the repository following the commit with SHA1 'since'.
		def commit_count(since=nil)
			run("#{rev_list_command(since)} | wc -l").to_i
		end

		# Returns the SHA1 hash for every commit in the repository following the commit with SHA1 'since'.
		def commit_tokens(since=nil)
			run(rev_list_command(since)).split("\n")
		end

		# Yields each commit following the commit with SHA1 'since'.
		# Officially, this method isn't required to provide diffs with these commits, and the Subversion equivalent of this method does not,
		# so if you really require the diffs you should be using each_commit() instead.
		def commits(since=nil)
			result = []
			each_commit(since) { |c| result << c }
			result
		end

		# Yields each commit following the commit with SHA1 'since'.
		# These commits are populated with diffs.
		def each_commit(since=nil)
			Scm::Parsers::GitStyledParser.parse(log(since)) do |e|
				yield e
			end
		end

		# Returns a single commit, including its diffs
		def verbose_commit(token)
			Scm::Parsers::GitStyledParser.parse(run("cd '#{url}' && #{Scm::Parsers::GitStyledParser.whatchanged} #{token}")).first
		end

		# Retrieves the git log in the format expected by GitStyledParser.
		# We get the log forward chronological order (oldest first)
		def log(since=nil)
			if has_branch?
				if since && since==self.head_token
					'' # Nothing new.
				else
					run "#{rev_list_command(since)} | xargs -n 1 #{Scm::Parsers::GitStyledParser.whatchanged}"
				end
			else
				''
			end
		end


		def rev_list_command(since=nil)
			rev_list_options = "--root --reverse --no-merges --topo-order"

			if since
				"cd '#{self.url}' && git rev-list #{rev_list_options} #{since}..HEAD #{self.branch_name}"
			else
				"cd '#{self.url}' && git rev-list #{rev_list_options} #{self.branch_name}"
			end
		end

	end
end
