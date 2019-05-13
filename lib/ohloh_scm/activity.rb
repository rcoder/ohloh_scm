# frozen_string_literal: true

module OhlohScm
  class Activity
    include OhlohScm::System
    extend Forwardable
    def_delegators :@base, :scm, :status

    def initialize(base)
      @base = base
    end

    def log_filename
      File.join(Dir.tmpdir, url.gsub(/\W/, '') + '.log')
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

    def cleanup; end
  end
end
