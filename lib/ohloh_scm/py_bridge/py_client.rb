# frozen_string_literal: true

module OhlohScm
  class PyClient
    def start
      @stdin, @stdout, @stderr, wait_thr = Open3.popen3 "python #{@py_script}"
      @pid = wait_thr[:pid]
      open_repository
    end

    def shutdown
      send_command('QUIT')
      [@stdin, @stdout, @stderr].reject(&:closed?).each(&:close)
      Process.waitpid(@pid, Process::WNOHANG)
    end

    private

    def send_command(cmd)
      # send the command
      @stdin.puts cmd
      @stdin.flush
      return if cmd == 'QUIT'

      # get status on stderr, first letter indicates state,
      # remaing value indicates length of the file content
      status = @stderr.read(10)
      flag = status[0, 1]
      size = status[1, 9].to_i
      return if flag == 'F'

      raise_subprocess_error(flag)

      # read content from stdout
      @stdout.read(size)
    end

    def raise_subprocess_error(flag)
      return unless flag == 'E'

      error = @stdout.read(size)
      raise "Exception in server process\n#{error}"
    end
  end
end
