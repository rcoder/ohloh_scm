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
			@buffer << "token:          #{commit.token.to_s}\n"
			@buffer << "committer name: #{commit.committer_name}\n"
			@buffer << "committer date: #{commit.committer_date}\n"

			if commit.author_name
				@buffer << "author name:    #{commit.author_name}\n"
				@buffer << "author date:    #{commit.author_date}\n"
			end

			if commit.diffs && commit.diffs.any?
				commit.diffs.each do |diff|
					@buffer << "                #{diff.action} #{diff.path}\n"
				end
			end

			if commit.directories && commit.directories.any?
				commit.directories.each do |d|
					@buffer << "                #{d}\n"
				end
			end

			if commit.message
				@buffer << "\n#{commit.message}\n"
			end
		end

		def write_postamble
		end
	end
end
