require 'rubygems'
require 'open4'
require 'stringio'

class BzrPipeClient
  def initialize(repository_url)
    @repository_url = repository_url
    @py_script = File.dirname(__FILE__) + '/bzrlib_pipe_server.py'
  end
  
  def start
    @pid, @stdin, @stdout, @stderr = Open4::popen4 "python #{@py_script}"
    open_repository
  end

  def open_repository
    send_command("REP_OPEN|#{@repository_url}")
  end
  def cat_file(revision, file)
    send_command("CAT_FILE|#{revision}|#{file}", true)
  end

  def parent_tokens(revision)
    send_command("PAR_TKNS|#{revision}", true).split('|')
  end

  def send_command(cmd, capture_output=false)
    #puts "COMMAND - #{cmd}"
    STDOUT.flush
    outbuf = StringIO.new
    errbuf = StringIO.new

    # send the command
    @stdin.puts cmd
    @stdin.flush

    # get status on stderr, first letter indicates state, 
    # remaing value indicates length of the file content
    status = @stderr.read(10)
    #puts "STATUS - #{status}"
    flag = status[0,1]
    size = status[1,10].to_i
    if flag == 'F'
      return nil
    elsif flag == 'E'
      error = @stdout.read(size)
      raise RuntimeError.new("Exception in server process\n#{error}")
    end

    # read content from stdout
    if capture_output
      return @stdout.read(size)
    end
  end

  def shutdown
    send_command("QUIT")
    Process.waitpid(@pid, Process::WNOHANG)
  end
end

def cat_all_files(client, datafile)
  count = 0
  bytes = 0
  File.open(datafile).each do |line|
    parts = line.split('|')
    count = count + 1
    bytes = bytes + client.cat_file(parts[0], parts[1]).size
    puts "file=#{count}, bytes=#{bytes}"
  end
end

def all_parent_tokens(client, datafile)
  File.open(datafile).each do |line|
    parts = line.split('|')
    puts client.parent_tokens(parts[0])
  end
end
