require 'parsedate'

module Scm::Parsers
	class HgParser < Parser
		def self.scm
			'hg'
		end

		def self.internal_parse(buffer, opts)
			e = nil
			state = :data

			buffer.each_line do |l|
				next_state = state
				if state == :data
					case l
					when /^changeset:\s+\d+:([0-9a-f]+)/
						e = Scm::Commit.new
						e.diffs = []
						e.token = $1
					when /^user:\s+(.+?)(\s+<(.+)>)?$/
						e.committer_name = $1
						e.committer_email = $3
					when /^date:\s+(.+)/
						e.committer_date = Time.local(*ParseDate.parsedate($1)).utc
					when /^files:\s+(.+)/
						($1 || '').split(' ').each do |file|
							e.diffs << Scm::Diff.new(:action => '?', :path => file)
						end
					when /^summary:\s+(.+)/
						e.message = $1
						yield e if block_given?
						e = nil
					when /^description:/
						next_state = :long_comment
					end

				elsif state == :long_comment
					if l == "\n"
						next_state = :long_comment_following_blank
					else
						e.message ||= ''
						e.message << l
					end

				elsif state == :long_comment_following_blank
					if l == "\n" # A second blank line in a row terminates the comment.
						yield e if block_given?
						e = nil
						next_state = :data
					else # Otherwise resume parsing comments.
						e.message << "\n"
						e.message << l
						next_state = :long_comment
					end
				end
				state = next_state
			end
		end
	end
end
