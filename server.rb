# http://docs.ruby-lang.org/en/2.2.0/TCPServer.html

require "socket"
 
class WebServer
  HEADER = "HTTP/1.1 200 OK\r\nContent-type: text/plain\r\n\r\n"

  def initialize(port, &handler)
    @port = port
    @handler = handler
  end

  def start
    server = TCPServer.new port

    loop do
      begin
        Thread.start(server.accept) do |socket|
          request = receive_request!(socket)
          socket.print HEADER
          handler.call(socket, request)
          socket.close
        end
      rescue Errno::EPIPE, IOError
        retry
      end
    end
  end

  private

  attr_reader :port, :handler

  def receive_request!(socket)
    request = []
    while line = socket.gets
      break if line =~ /^\s*$/
      request << line.chomp
    end
    request
  end
end

port = ENV["PORT"] or raise "Must set PORT environment variable"

web_server = WebServer.new(port) do |socket, request|
  socket.puts "Hello world! #{Time.now}"
  socket.puts
  socket.puts request
end

web_server.start
