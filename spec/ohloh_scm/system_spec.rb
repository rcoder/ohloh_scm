require 'spec_helper'

describe 'System' do
  describe 'run' do
    before do
      @object = Object.new
      @object.extend(OhlohScm::System)
    end

    it 'must run a command succesfully' do
      @object.run('ls /tmp')
    end

    it 'must raise an exception when command fails' do
      -> { @object.run('ls /tmp/foobartest') }.must_raise(Exception)
    end
  end
end
