require 'parsedate'
require 'rexml/document'
require 'rexml/streamlistener'

module Scm::Parsers
	class SubversionListener
		include REXML::StreamListener

		attr_accessor :callback
		def initialize(callback)
			@callback = callback
		end

		attr_accessor :text, :commit, :diff

		def tag_start(name, attrs)
			case name
			when 'logentry'
				@commit = Scm::Commit.new
				@commit.token = attrs['revision'].to_i
			when 'path'
				@diff = Scm::Diff.new(:action => attrs['action'])
			end
		end

		def tag_end(name)
			case name
			when 'logentry'
				@callback.call(@commit)
			when 'author'
				@commit.committer_name = @text
			when 'date'
				@commit.committer_date = Time.utc(*ParseDate.parsedate(@text))
			when 'path'
				@diff.path = @text
				@commit.diffs ||= []
				@commit.diffs << @diff
			when 'msg'
				@commit.message = @text
			end
		end

		def text(text)
			@text = text
		end
	end

	class SvnXmlParser < Parser
		def self.internal_parse(buffer, opts)
			begin
				REXML::Document.parse_stream(buffer, SubversionListener.new(Proc.new { |c| yield c if block_given? }))
			rescue EOFError
			end
		end

		def self.scm
			'svn'
		end
	end
end
