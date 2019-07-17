# frozen_string_literal: true

require 'spec_helper'

describe 'Bzr::Scm' do
  it 'must pull the repository correctly' do
    with_bzr_repository('bzr') do |src|
      tmpdir do |dest_dir|
        core = OhlohScm::Factory.get_core(scm_type: :bzr, url: dest_dir)
        refute core.status.scm_dir_exist?

        core.scm.pull(src.scm, TestCallback.new)
        assert core.status.scm_dir_exist?
        assert core.status.exist?
      end
    end
  end
end
