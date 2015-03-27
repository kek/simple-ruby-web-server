# http://docs.ruby-lang.org/en/2.2.0/TCPServer.html

require "socket"
 
HEADER = "HTTP/1.1 200 OK\r\nContent-type: text/plain\r\n\r\n"
port = ENV["PORT"] or raise "Must set PORT environment variable"
server = TCPServer.new port

begin
  while socket = server.accept
    request = []
    while line = socket.gets
      request << line.chomp
      break if line =~ /^\s*$/
    end

    socket.print HEADER

    socket.puts "Hello world!"
    socket.puts request[0]
    socket.puts Time.now

    socket.close
  end
rescue Errno::EPIPE
  retry
end
