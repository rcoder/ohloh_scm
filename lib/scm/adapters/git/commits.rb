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
			Git::LogParser.parse(log(since)) do |e|
				yield e
			end
		end

		# Command line to output a single commit.
		# We use a special format string so that we can get the date in a format Ruby can parse.
		WHATCHANGED="git whatchanged --root --abbrev=40 --max-count=1 --pretty=format:'__BEGIN_COMMIT__%nCommit: %H%nAuthor: %an%nAuthorEmail: %ae%nDate: %aD%n__BEGIN_COMMENT__%n%s%n%b%n__END_COMMENT__'" unless defined?(WHATCHANGED)

		REV_LIST_OPTIONS=" --root --reverse --no-merges --topo-order " unless defined?(REV_LIST_OPTIONS)

		# Retrieves the git log in the format expected by Git::LogParser.
		# We get the log forward chronological order (oldest first)
		def log(since=nil)
			if has_branch?
				if since && since==self.head
					'' # Nothing new.
				else
					run "#{rev_list_command(since)} | xargs -n 1 #{WHATCHANGED}"
				end
			else
				''
			end
		end

		def rev_list_command(since=nil)
			if since
				"cd '#{self.url}' && git rev-list #{REV_LIST_OPTIONS} #{since}..HEAD #{self.branch_name}"
			else
				"cd '#{self.url}' && git rev-list #{REV_LIST_OPTIONS} #{self.branch_name}"
			end
		end

	end
end
