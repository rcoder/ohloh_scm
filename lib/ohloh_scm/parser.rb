# frozen_string_literal: true

require_relative 'parser/array_writer'
require_relative 'parser/branch_number'

module OhlohScm
  class Parser
    class << self
      def parse(buffer = '', opts = {})
        buffer = StringIO.new(buffer) if buffer.is_a?(String)
        writer = ArrayWriter.new unless block_given?

        internal_parse(buffer, opts) do |commit|
          if commit
            yield commit if block_given?
            writer&.write_commit(commit)
          end
        end

        writer&.buffer
      end

      def internal_parse; end
    end
  end
end

require_relative 'parser/git_parser'
require_relative 'parser/cvs_parser'
require_relative 'parser/svn_parser'
