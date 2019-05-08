# frozen_string_literal: true

require 'spec_helper'

describe 'BzrScm' do
  it 'must pull the repository correctly' do
    with_bzr_repository('bzr') do |src|
      tmpdir do |dest_dir|
        base = OhlohScm::Factory.get_base(scm_type: :bzr, url: dest_dir)
        refute base.status.exist?

        base.scm.pull(src.scm)
        assert base.status.exist?
      end
    end
  end
end
