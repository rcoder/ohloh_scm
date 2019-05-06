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

  describe 'run_with_error' do
    it 'must provide error and exitstatus' do
      cmd = %q(ruby -e"  t = 'Hello World'; STDOUT.puts t; STDERR.puts t  ")
      stdout, stderr, status = run_with_error_p(cmd)
      status.exitstatus.must_equal 0
      stdout.must_equal "Hello World\n"
      stderr.must_equal "Hello World\n"
    end
  end
end
