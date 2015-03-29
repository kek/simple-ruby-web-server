# http://docs.ruby-lang.org/en/2.2.0/TCPServer.html

require "socket"
 
port = ENV["PORT"] or raise "Must set PORT environment variable"
server = TCPServer.new port

loop do
  begin
    Thread.start(server.accept) do |socket|
      request = []
      while line = socket.gets
        break if line =~ /^\s*$/
        request << line.chomp
      end

      socket.print "HTTP/1.1 200 OK\r\nContent-type: text/plain\r\n\r\n"

      socket.puts "Hello world! #{Time.now}"
      socket.puts
      socket.puts request

      socket.close
    end
  rescue Errno::EPIPE, IOError
    retry
  end
end
