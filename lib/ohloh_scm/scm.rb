# frozen_string_literal: true

module OhlohScm
  class Scm
    include OhlohScm::System
    extend Forwardable
    def_delegators :@base, :status, :activity
    attr_reader :url, :branch_name, :username, :password

    def initialize(base:, url:, branch_name: nil, username: nil, password: nil)
      @base = base
      @url = url.strip if url
      @branch_name = branch_name.strip if branch_name
      @username = username.strip if username
      @password = password.strip if password
    end

    def normalize; end

    def pull; end
  end
end
