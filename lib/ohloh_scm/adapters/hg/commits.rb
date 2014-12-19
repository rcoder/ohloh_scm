module OhlohScm::Adapters
	class HgAdapter < AbstractAdapter

		# Return the number of commits in the repository following +after+.
		def commit_count(opts={})
			commit_tokens(opts).size
		end

		# Return the list of commit tokens following +after+.
		def commit_tokens(opts={})
			after = opts[:after] || 0
			up_to = opts[:up_to] || 'tip'

			# We reverse the final result in Ruby, rather than passing the --reverse flag to hg.
			# That's because the -f (follow) flag doesn't behave the same in both directions.
			# Basically, we're trying very hard to make this act just like Git. The hg_rev_list_test checks this.
			tokens = run("cd '#{self.url}' && hg log -f #{trunk_only(opts)} -r #{up_to || 'tip'}:#{after || 0} --template='{node}\\n'").split("\n").reverse

			# Hg returns everything after *and including* after.
			# We want to exclude it.
			if tokens.any? && tokens.first == after
				tokens[1..-1]
			else
				tokens
			end
		end

		# Returns a list of shallow commits (i.e., the diffs are not populated).
		# Not including the diffs is meant to be a memory savings when we encounter massive repositories.
		# If you need all commits including diffs, you should use the each_commit() iterator, which only holds one commit
		# in memory at a time.
		def commits(opts={})
			after = opts[:after] || 0

			log = run("cd '#{self.url}' && hg log -f #{trunk_only(opts)} -v -r tip:#{after} --style #{OhlohScm::Parsers::HgStyledParser.style_path}")
			a = OhlohScm::Parsers::HgStyledParser.parse(log).reverse

			if a.any? && a.first.token == after
				a[1..-1]
			else
				a
			end
		end

		# Returns a single commit, including its diffs
		def verbose_commit(token)
			log = run("cd '#{self.url}' && hg log -v -r #{token} --style #{OhlohScm::Parsers::HgStyledParser.verbose_style_path} | #{ string_encoder }")
			OhlohScm::Parsers::HgStyledParser.parse(log).first
		end

		# Yields each commit after +after+, including its diffs.
		# The log is stored in a temporary file.
		# This is designed to prevent excessive RAM usage when we encounter a massive repository.
		# Only a single commit is ever held in memory at once.
		def each_commit(opts={})
			after = opts[:after] || 0
			open_log_file(opts) do |io|
				OhlohScm::Parsers::HgStyledParser.parse(io) do |commit|
					yield commit if block_given? && commit.token != after
				end
			end
		end

		# Not used by Ohloh proper, but handy for debugging and testing
		def log(opts={})
			after = opts[:after] || 0
			run "cd '#{url}' && hg log -f #{trunk_only(opts)} -v -r tip:#{after} | #{ string_encoder }"
		end

		# Returns a file handle to the log.
		# In our standard, the log should include everything AFTER +after+. However, hg doesn't work that way;
		# it returns everything after and INCLUDING +after+. Therefore, consumers of this file should check for
		# and reject the duplicate commit.
		def open_log_file(opts={})
			after = opts[:after] || 0
			begin
				if after == head_token # There are no new commits
					# As a time optimization, just create an empty file rather than fetch a log we know will be empty.
					File.open(log_filename, 'w') { }
				else
					run "cd '#{url}' && hg log --verbose #{trunk_only(opts)} -r #{after || 0}:tip --style #{OhlohScm::Parsers::HgStyledParser.verbose_style_path} | #{ string_encoder } > #{log_filename}"
				end
				File.open(log_filename, 'r') { |io| yield io }
			ensure
				File.delete(log_filename) if FileTest.exist?(log_filename)
			end
		end

		def log_filename
		  File.join('/tmp', (self.url).gsub(/\W/,'') + '.log')
		end

		def trunk_only(opts={})
			if opts[:trunk_only]
				'--follow-first'
			else
				''
			end
		end

	end
end
