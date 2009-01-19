module Scm::Adapters::Git
	class LogParser

		NO_AUTHOR='(no author)'

		def self.parse io
			e = nil
			state = :key_values

			io.each do |line|
				line.chomp!

				# Kind of a hack: the diffs section is not always present.
				# If we are expecting a line of diffs, but instead find a line
				# starting with "Commit: ", that means the diffs section
				# is missing for this commit,  and we need to fix up our state.
				if state == :diffs and line =~ /^Commit: ([a-z0-9]+)$/
					state = :key_values
				end

				if state == :key_values
					if line =~ /^Commit: ([a-z0-9]+)$/
						sha1 = $1
						yield e if e
						e = Scm::Commit.new
						e.diffs = []
						e.token = sha1
						e.author_name = NO_AUTHOR
					elsif line =~ /^Author: (.+)$/
						e.author_name = $1
					elsif line =~ /^Date: (.*)$/
						e.author_date = Time.parse($1).utc # Note strongly: MUST be RFC2822 format to parse properly
					elsif line == "__BEGIN_COMMENT__"
						state = :message
					elsif line =~ /^AuthorEmail: (.+)$/
						e.author_email = $1
						# In the rare case that the Git repository does not contain any names (see OpenEmbedded for example)
						# we use the email instead.
						e.author_name = $1 if e.author_name.to_s.empty? || e.author_name == NO_AUTHOR
					end

				elsif state == :message
					if line == "__END_COMMENT__"
						state = :diffs
					elsif line != "<unknown>"
						if e.message
							e.message << "\n" << line
						else
							e.message = line
						end
					end

				elsif state == :diffs
					if line == "__BEGIN_COMMIT__"
						state = :key_values
					elsif line =~ /:([0-9]+) ([0-9]+) ([a-z0-9]+) ([a-z0-9]+) ([A-Z])\t"?(.+[^"])"?$/
						# Submodules have a file mode of '160000', which indicates a "gitlink"
						# We ignore submodules completely.
						e.diffs << Scm::Diff.new( :action => $5, :path => $6, :sha1 => $4, :parent_sha1 => $3 ) unless $1=='160000' || $2=='160000'
					end

				else
					raise RuntimeError("Unknown parser state #{state.to_s}")
				end
			end

			yield e if e
		end
	end
end
