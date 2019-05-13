# frozen_string_literal: true

module OhlohScm
  class Scm
    include OhlohScm::System
    extend Forwardable
    def_delegators :@base, :status, :activity
    attr_reader :url, :username, :password
    attr_accessor :branch_name

    def initialize(base:, url:, branch_name: nil, username: nil, password: nil)
      @base = base
      @url = url.strip if url
      @branch_name = branch_name&.strip
      @branch_name = nil if branch_name&.empty?
      @username = username&.strip
      @password = password&.strip
    end

    def normalize; end

    def pull; end

    def vcs_path; end
  end
end
