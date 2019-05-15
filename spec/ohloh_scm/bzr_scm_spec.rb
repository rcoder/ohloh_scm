# frozen_string_literal: true

require 'spec_helper'

describe 'BzrScm' do
  it 'must pull the repository correctly' do
    with_bzr_repository('bzr') do |src|
      tmpdir do |dest_dir|
        core = OhlohScm::Factory.get_core(scm_type: :bzr, url: dest_dir)
        refute core.status.exist?

        core.scm.pull(src.scm)
        assert core.status.exist?
      end
    end
  end
end
