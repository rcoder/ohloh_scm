module OhlohScm::Parsers
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
			@buffer << "--------------- #{'-' * 40}\n"
			@buffer << "token:          #{commit.token.to_s}\n"

			@buffer << "committer name: #{commit.committer_name}\n" if commit.committer_name
			@buffer << "committer mail: <#{commit.committer_email}>\n" if commit.committer_email
			@buffer << "committer date: #{commit.committer_date}\n" if commit.committer_date

			@buffer << "author name:    #{commit.author_name}\n" if commit.author_name
			@buffer << "author mail:    <#{commit.author_email}>\n" if commit.author_email
			@buffer << "author date:    #{commit.author_date}\n" if commit.author_date

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
				@buffer << "\n#{commit.message}"
				@buffer << "\n" unless commit.message[-1..-1] == "\n"
			end

			@buffer << "\n"
		end

		def write_postamble
		end
	end
end
