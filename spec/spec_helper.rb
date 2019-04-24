# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

require 'ohloh_scm'
require 'minitest'
require 'minitest/autorun'
require 'faker'
require 'helpers/repository_helper'

FIXTURES_DIR = File.expand_path('raw_fixtures', __dir__)

module Minitest
  class Test
    include RepositoryHelper
  end
end
