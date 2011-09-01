require 'rubygems'
require 'stringio'
require 'open4'

class Shellout

  def self.relay src, dst
    while((buf = src.read(8192))); dst << buf; end 
  end 

  def self.run(cmd)
    outbuf = StringIO.new
    errbuf = StringIO.new
    status = Open4::popen4("sh") do | pid, stdin, stdout, stderr |
      stdin.puts cmd
      stdin.close
      to = Thread.new { relay stdout, outbuf }
      te = Thread.new { relay stderr, errbuf }
      to.join
      te.join
    end
    return status, outbuf.string, errbuf.string
  end

end

if $0 == __FILE__
  date = %q( ruby -e"  t = Time.now; STDOUT.puts t; STDERR.puts t  " )
  status, stdout, stderr = Shellout.run(date)
  p [status.exitstatus, stdout, stderr]

  sleep = %q( ruby -e"  p(sleep(1))  " )
  status, stdout, stderr = Shellout.run(sleep)
  p [status.exitstatus, stdout, stderr]

  cat = 'ruby -e"  puts Array.new(65536){ 42 }  "'
  status, stdout, stderr = Shellout.run(cat)
  p [status.exitstatus, stdout, stderr]

  status, stdout, stderr = Shellout.run('osiudfoisynajtet32')
  p [status.exitstatus, stdout, stderr]

end


