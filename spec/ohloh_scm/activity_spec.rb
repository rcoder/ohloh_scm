# frozen_string_literal: true

require 'spec_helper'

describe 'Activity' do
  describe 'log_filename' do
    it 'should return system tmp dir path' do
      core = get_core(:git)
      scm = OhlohScm::Activity.new(core)
      scm.log_filename.must_equal "#{Dir.tmpdir}/foobar.log"
    end

    it 'should return temp folder path' do
      core = get_core(:git)
      core.temp_dir = '/test'
      scm = OhlohScm::Activity.new(core)
      scm.log_filename.must_equal '/test/foobar.log'
    end
  end
end
