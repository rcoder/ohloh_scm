# frozen_string_literal: true

module OhlohScm
  class Scm
    extend Forwardable
    def_delegators :@base, :status, :activity
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
