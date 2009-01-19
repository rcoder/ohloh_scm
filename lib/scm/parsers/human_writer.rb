module Scm::Parsers
	class HumanWriter
		# Note that we use << instead of write() or puts() in this writer because
		# the << operator works on both File and String objects.

		attr_accessor :buffer
		def initialize(buffer='')
			@buffer = buffer
		end

		def write_preamble(opts = {})
		end

		def write_commit(commit)
			@buffer << "-" * 72 + "\n"

			@buffer << commit.token.to_s
			@buffer << ' | Committer: '
			@buffer << commit.committer_name.to_s.ljust(24)
			@buffer << ' | '
			@buffer << commit.committer_date.to_s
			@buffer << "\n"

			if commit.author_name
				@buffer << ' ' * commit.token.to_s.length
				@buffer << ' | Author:    '
				@buffer << commit.author_name.to_s.ljust(24)
				@buffer << ' | '
				@buffer << commit.author_date.to_s
				@buffer << "\n"
			end

			if commit.diffs && commit.diffs.any?
				commit.diffs.each { |diff| write_diff(diff) }
			end

			if commit.directories && commit.directories.any?
				commit.directories.each do |d|
					@buffer << "\t#{d}\n"
				end
			end

			if commit.message
				@buffer << "\n#{commit.message}\n"
			end
		end

		def write_diff(diff)
			@buffer << "\t#{diff.action} #{diff.path}\n"
		end

		def write_postamble
		end
	end
end
