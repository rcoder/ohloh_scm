# frozen_string_literal: true

module OhlohScm
  class Status
    include OhlohScm::System
    extend Forwardable
    def_delegators :@core, :scm, :activity
    attr_reader :errors

    def initialize(core)
      @core = core
    end

    def exist?
      return unless scm_dir_exist?

      !activity.head_token.to_s.empty?
    end

    def scm_dir_exist?
      Dir.exist?(scm.vcs_path)
    end
  end
end
