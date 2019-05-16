require 'spec_helper'

describe 'Git::Status' do
  it 'branch?' do
    with_git_repository('git') do |git|
      git.activity.send(:branches).must_equal %w[develop master]
      assert git.status.branch? # checks master.
      assert git.status.branch?('develop')
    end
  end
end
