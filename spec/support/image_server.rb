# frozen_string_literal: true

require 'socket'

# A loopback HTTP fixture server; no public network or additional gems required.
class ImageServer
  attr_reader :requests

  def initialize
    @socket = TCPServer.new('127.0.0.1', 0)
    @requests = []
    @thread = Thread.new { serve }
  end

  def url
    "http://127.0.0.1:#{@socket.addr[1]}"
  end

  def close
    @thread.kill
    @thread.join
    @socket.close
  end

  private

  def serve
    loop do
      client = @socket.accept
      begin
        respond(client)
      ensure
        client.close
      end
    end
  end

  def read_request(client)
    request = client.gets.split
    while (header = client.gets)
      break if header == "\r\n"
    end
    request
  end

  def respond(client)
    method, path = read_request(client)
    @requests << path
    found = path == '/image.png'
    body = found ? File.binread(File.expand_path('../fixtures/image.png', __dir__)) : 'Not found'
    status = found ? '200 OK' : '404 Not Found'
    client.write("HTTP/1.1 #{status}\r\nContent-Type: image/png\r\n" \
                 "Content-Length: #{body.bytesize}\r\nConnection: close\r\n\r\n")
    client.write(body) unless method == 'HEAD'
  end
end
