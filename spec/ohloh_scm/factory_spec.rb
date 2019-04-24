# frozen_string_literal: true

require 'spec_helper'

describe 'Factory' do
  it 'must provide access to scm, activity and status functions' do
    url = Faker::Internet.url
    base = OhlohScm::Factory.get_scm(scm_type: :git, url: url)

    base.status.scm.must_be_instance_of OhlohScm::GitScm
    base.scm.url.must_equal url
    assert base.activity.method(:commits)
    assert base.status.method(:logger)
  end
end
