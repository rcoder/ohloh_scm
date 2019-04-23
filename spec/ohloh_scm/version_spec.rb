# frozen_string_literal: true

require 'spec_helper'

describe 'Version' do
  it 'must return the version string' do
    OhlohScm::Version::STRING.must_be_instance_of String
  end
end
