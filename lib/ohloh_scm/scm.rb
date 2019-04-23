# frozen_string_literal: true

module OhlohScm
  class Scm
    attr_reader :url, :branch_name

    def initialize(base:, url:, branch_name: nil)
      @base = base
      @url = url
      @branch_name = branch_name
    end

    def normalize; end

    def pull; end
  end
end
