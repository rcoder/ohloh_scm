# frozen_string_literal: true

module OhlohScm
  class Status
    extend Forwardable
    def_delegators :@base, :scm, :activity

    def initialize(base)
      @base = base
    end

    def validate; end

    def validate_server_connection; end

    def errors; end

    def cleanup; end

    def logger; end
  end
end
