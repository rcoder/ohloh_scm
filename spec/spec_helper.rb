# frozen_string_literal: true

$LOAD_PATH << File.expand_path('../lib', __dir__)

if ENV['SIMPLECOV_START']
  require 'simplecov'
  SimpleCov.start { add_filter '/spec/' }
  SimpleCov.minimum_coverage 94
end

require 'ohloh_scm'
require 'minitest'
require 'mocha/minitest'
require 'minitest/autorun'
require 'helpers/repository_helper'
require 'helpers/system_helper'
require 'helpers/generic_helper'
require 'helpers/commit_tokens_helper'
require 'helpers/assert_scm_attr_helper'

FIXTURES_DIR = File.expand_path('raw_fixtures', __dir__)

module Minitest
  class Test
    include RepositoryHelper
    include SystemHelper
    include GenericHelper
    include AssertScmAttrHelper
  end
end

class TestCallback; def update(_, _); end; end
