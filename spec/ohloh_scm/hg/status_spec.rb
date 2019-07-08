require 'spec_helper'

describe 'Hg::Status' do
  it 'exist? must check if repo exists' do
    hg_repo = nil
    with_hg_repository('hg') do |hg|
      hg_repo = hg
      assert hg_repo.status.exist?
    end
    refute hg_repo.status.exist?
  end
end
