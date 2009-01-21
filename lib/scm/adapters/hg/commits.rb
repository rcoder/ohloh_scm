module Scm::Adapters
	class HgAdapter < AbstractAdapter

		# Return the number of commits in the repository following +since+.
		def commit_count(since=0)
			commit_tokens(since).size
		end

		# Return the list of commit tokens following +since+.
		def commit_tokens(since=0)
			tokens = run("cd '#{self.url}' && hg log -r #{since}:tip --template='{node}\\n'").split("\n")

			# Hg returns everything after *and including* since.
			# We do not want to include it.
			if tokens.any? && tokens.first == since	
				tokens[1..-1]
			else
				tokens
			end
		end

		# Returns a list of shallow commits (i.e., the diffs are not populated).
		# Not including the diffs is meant to be a memory savings when we encounter massive repositories.
		# If you need all commits including diffs, you should use the each_commit() iterator, which only holds one commit
		# in memory at a time.
		def commits(since=0)
			log = run("cd '#{self.url}' && hg log -v -r #{since}:tip --style #{Scm::Parsers::HgStyledParser.style_path}")
			a = Scm::Parsers::HgStyledParser.parse(log)

			if a.any? && a.first.token == since
				a[1..-1]
			else
				a
			end
		end
	end
end
