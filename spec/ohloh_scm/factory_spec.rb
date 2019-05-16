# frozen_string_literal: true

require 'spec_helper'

describe 'Factory' do
  it 'must provide access to scm, activity and status functions' do
    url = 'https://foobar.git'
    core = OhlohScm::Factory.get_core(scm_type: :git, url: url)

    core.status.scm.must_be_instance_of OhlohScm::Git::Scm
    core.scm.url.must_equal url
    assert core.activity.method(:commits)
    assert core.status.method(:exist?)
    assert core.validation.method(:validate)
  end
end
