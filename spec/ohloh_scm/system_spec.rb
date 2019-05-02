require 'spec_helper'

describe 'System' do
  describe 'run' do
    it 'must run a command succesfully' do
      run_p('ls /tmp')
    end

    it 'must raise an exception when command fails' do
      -> { run_p('ls /tmp/foobartest') }.must_raise(Exception)
    end
  end
end
