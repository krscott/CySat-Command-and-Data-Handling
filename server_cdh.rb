require_relative 'cdh'
require_relative 'socket_server'

class Demo < SocketConnection
  def initialize(*a)
    super(*a)
    @micro = Microprocessor.new
    @micro.on_output do |out|
      sprint out
    end
  end
  
  def on_connect()
    super
    @micro.run
    close
  end
end

if $0 == __FILE__
  SocketServer.new(2000).run(Demo)
end
