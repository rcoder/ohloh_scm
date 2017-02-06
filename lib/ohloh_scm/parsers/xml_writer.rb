module OhlohScm::Parsers
	class XmlWriter
		# Note that we use << instead of write() or puts() in this writer because
		# the << operator works on both File and String objects.

		attr_accessor :buffer
		def initialize(buffer='')
			@buffer = buffer
		end

		def write_preamble(opts = {})
			@buffer << "<?xml version=\"1.0\"?>\n"
			@buffer << "<ohloh_log"
			opts.each_key do |key|
				next if key.to_s == 'writer'
				@buffer << " #{key}=\"#{opts[key]}\""
			end
			@buffer << ">\n"
		end

		def write_commit(commit)
			@buffer << "    <commit token=\"#{commit.token}\">\n"

			if commit.author_name
				@buffer << "        <author name=\"#{commit.author_name}\" date=\"#{xml_time(commit.author_date)}\" />\n"
			end

			if commit.committer_name
				@buffer << "        <committer name=\"#{commit.committer_name}\" date=\"#{xml_time(commit.committer_date)}\" />\n"
			end

			if commit.message
				@buffer << "        <message>#{commit.message}</message>\n"
			end

			if commit.diffs && commit.diffs.any?
				@buffer << "        <diffs>\n"
				commit.diffs.each { |diff| write_diff(diff) }
				@buffer << "        </diffs>\n"
			end

			@buffer << "    </commit>\n"
		end

		def write_diff(diff)
			@buffer << "            <diff action=\"#{diff.action}\" path=\"#{diff.path}\" />\n"
		end

		def write_postamble
			@buffer << "</ohloh_log>\n"
		end

		def xml_time(time)
			case time
			when Time
				time.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
			when String
				time
			end
		end
	end
end
