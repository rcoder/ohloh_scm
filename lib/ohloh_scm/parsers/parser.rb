require 'stringio'

module OhlohScm::Parsers
	class Parser
		def self.parse(buffer='', opts={})
			buffer = StringIO.new(buffer) if buffer.is_a? String
			opts = opts.merge(:scm => self.scm)

			writer = (opts[:writer] || ArrayWriter.new) unless block_given?
			writer.write_preamble(opts) if writer

			internal_parse(buffer, opts) do |commit|
				if commit
					yield commit if block_given?
					writer.write_commit(commit) if writer
				end
			end

			if writer
				writer.write_postamble
				writer.buffer
			else
				nil
			end
		end

		def self.internal_parse
		end

		def self.scm
			nil
		end
	end
end
