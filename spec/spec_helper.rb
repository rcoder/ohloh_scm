# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

if ENV['SIMPLECOV_START']
  require 'simplecov'
  SimpleCov.start { add_filter '/spec/' }
  SimpleCov.minimum_coverage 94
end

require 'ohloh_scm'
require 'minitest'
require 'minitest/autorun'
require 'helpers/repository_helper'

FIXTURES_DIR = File.expand_path('raw_fixtures', __dir__)

module Minitest
  class Test
    include RepositoryHelper
  end
end
