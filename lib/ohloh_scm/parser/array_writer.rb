# frozen_string_literal: true

module OhlohScm
  class ArrayWriter
    attr_accessor :buffer

    def initialize(buffer = [])
      @buffer = buffer
    end

    def write_commit(commit)
      @buffer << commit
    end
  end
end
