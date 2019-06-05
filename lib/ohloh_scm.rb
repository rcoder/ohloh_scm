# frozen_string_literal: true

module OhlohScm
end

require 'time'
require 'tmpdir'
require 'forwardable'
require 'nokogiri'

require 'ohloh_scm/string_extensions'
require 'ohloh_scm/version'
require 'ohloh_scm/system'
require 'ohloh_scm/diff'
require 'ohloh_scm/commit'
require 'ohloh_scm/parser'
require 'ohloh_scm/core'
require 'ohloh_scm/scm'
require 'ohloh_scm/activity'
require 'ohloh_scm/status'
require 'ohloh_scm/validation'
require 'ohloh_scm/py_bridge'

require 'ohloh_scm/hg'
require 'ohloh_scm/git'
require 'ohloh_scm/bzr'
require 'ohloh_scm/cvs'
require 'ohloh_scm/svn'
require 'ohloh_scm/git_svn'

require 'ohloh_scm/factory'

`#{File.expand_path('../.bin/check_scm_version', __dir__)}`
