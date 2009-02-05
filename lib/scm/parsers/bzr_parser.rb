module Scm::Parsers
	# This parser can process the default bzr logs, with or without the --verbose flag.
	class BzrParser < Parser
		def self.scm
			'bzr'
		end

		def self.internal_parse(buffer, opts)
			e = nil
			state = :data
			action = ''
			show_id = false # true if this log includes revision and file ids

			buffer.each_line do |l|
				next_state = state

				case l
				when /^-+$/
					# a new commit begins
					yield e if e && block_given?
					e = Scm::Commit.new
					e.diffs = []
					next_state = :data
				when /^revno:\s+(\d+)$/
					e.token = $1
					next_state = :data
				when /^revision-id:\s+(\S+)$/
					e.token = $1
					show_id = true
					next_state = :data
				when /^committer:\s+(.+?)(\s+<(.+)>)?$/
					e.committer_name = $1
					e.committer_email = $3
					next_state = :data
				when /^timestamp:\s+(.+)/
					e.committer_date = Time.parse($1)
					next_state = :data
				when /^added:$/
					next_state = :collect_files
					action = 'A'
				when /^modified:$/
					next_state = :collect_files
					action = 'M'
				when /^removed:$/
					next_state = :collect_files
					action = 'D'
				when /^message:$/
					next_state = :collect_message
					e.message ||= ''
				when /^  (.*)$/
					case state
					when :collect_files
						path = $1
						# strip the id from the filename if it is present
						path = $1 if show_id && path =~ /^(.+?)\s+(\S+)$/
						e.diffs << Scm::Diff.new(:action => action, :path => path)
					when :collect_message
						e.message << $1
						e.message << "\n"
					end
				end

				state = next_state
			end
			yield e if e && block_given?
		end

	end
end
