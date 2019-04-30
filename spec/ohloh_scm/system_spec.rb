require 'spec_helper'

describe 'System' do
  describe 'run' do
    before do
      @object = Object.new
      @object.extend(OhlohScm::System)
      def @object.run_p(cmd)
        run(cmd)
      end
    end

    it 'must run a command succesfully' do
      @object.run_p('ls /tmp')
    end

    it 'must raise an exception when command fails' do
      -> { @object.run_p('ls /tmp/foobartest') }.must_raise(Exception)
    end
  end
end
