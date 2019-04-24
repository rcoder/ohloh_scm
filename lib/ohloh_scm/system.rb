# frozen_string_literal: true

require 'logger'

module OhlohScm
  module System
    def run(cmd)
      system(cmd)
    end

    def logger
      self.class.logger
    end

    def self.logger
      @logger ||= Logger.new(STDERR)
    end

    def string_encoder_path
      File.expand_path('../../.bin/string_encoder', __dir__)
    end
  end
end
