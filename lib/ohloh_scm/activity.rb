# frozen_string_literal: true

module OhlohScm
  class Activity
    extend Forwardable
    def_delegators :@base, :scm, :status, :run, :string_encoder_path

    def initialize(base)
      @base = base
    end

    def tags; end

    def export; end

    def export_tag; end

    def head_token; end

    def each_commit; end

    def commits; end

    def commit_tokens; end

    def commit_count; end

    def diffs; end
  end
end
