require 'socket'

class ChatServer

  def initialize(port)

    @descriptors = Array::new
    # @serverSocket = TCPServer.new("", port)
    @serverSocket = TCPServer.new("", port)

    @serverSocket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1)
    printf("Chat server start on port %d\n", port)
    @descriptors.push(@serverSocket)

  end

  def run
    while 1
      res = select(@descriptors, nil, nil, nil)
      if res != nil then
        for sock in res[0]
          if sock == @serverSocket then
            accept_new_connection
          else
            if sock.eof? then
              str = sprintf("Client left %s:%s\n", sock.peeraddr[2], sock.peeraddr[1])
              broadcast_string(str, sock)
              sock.close
              @descriptors.delete(sock)
            else
              str = sprintf("[%s|%s]: %s", sock.peeraddr[2], sock.peeraddr[1], sock.gets())
              broadcast_string(str, sock)
            end
          end
        end
      end
    end
  end

  def broadcast_string(str, omit_sock)
    @descriptors.each do |clisock|
      if clisock != @serverSocket && clisock != omit_sock
        clisock.write(str)
      end
    end
  end

  def accept_new_connection
    newsock = @serverSocket.accept
    @descriptors.push(newsock)
    newsock.write("You have been accepted into the Ruby Chat Server!\n")
    str = sprintf("Client joined %s:%s\n", newsock.peeraddr[2], newsock.peeraddr[1])
    broadcast_string(str, newsock)
  end

end

chatServer = ChatServer.new(8888)
chatServer.run