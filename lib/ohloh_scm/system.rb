# frozen_string_literal: true

require 'logger'

module OhlohScm
  module System
    def run(cmd)
      `#{cmd}`
    end

    def string_encoder_path
      File.expand_path('../../.bin/string_encoder', __dir__)
    end

    class << self
      def logger
        @logger ||= Logger.new(STDERR)
      end
    end
  end
end
