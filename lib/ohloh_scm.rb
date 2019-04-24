# frozen_string_literal: true

module OhlohScm
end

require 'forwardable'

require_relative 'ohloh_scm/version'
require_relative 'ohloh_scm/system'
require_relative 'ohloh_scm/base'
require_relative 'ohloh_scm/scm'
require_relative 'ohloh_scm/activity'
require_relative 'ohloh_scm/status'

require_relative 'ohloh_scm/git_scm'
require_relative 'ohloh_scm/git_activity'
require_relative 'ohloh_scm/git_status'

require_relative 'ohloh_scm/factory'
