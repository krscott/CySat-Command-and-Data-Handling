require 'socket'

class SocketConnection
  attr_reader :socket, :addr
  def initialize(socket, server=nil)
    @socket = socket
    @server = server
    @addr = socket.addr[2]
    @closed = false
  end
  
  def sputs(str)
    socket.puts str.to_s unless socket.closed? or @closed
  end
  def sprint(str)
    socket.print str.to_s unless socket.closed? or @closed
  end

  def server_puts(str)
    puts "[#{timestamp}] #{str}"
  end

  def closed?()
    socket.closed? or @closed
  end
  
  def close()
    @closed = true
    on_close()
  end
  
  def to_s()
    "#{addr}"
  end
  
  def run()
    begin
      on_connect()
      while !socket.closed? && !@closed
        rx = socket.gets
        next if rx.nil?
        rx.chomp!
        on_input(rx)
        socket.flush
      end
    rescue Errno::ECONNRESET => e
      close
    rescue Errno::EPIPE => e
      close
    rescue Exception => e
      server_puts "Rescued Exception."
      puts "#{e} (#{e.class})"
      puts e.backtrace.map{|x| "  #{x}"}
    end
    socket.close unless socket.closed?
  end
  
  private
  
  def timestamp()
    Time.now.localtime.to_s.gsub(/ -.*$/,'')
  end

  def input_not_recognized(s)
    sputs "I don't understand '#{s}'"
  end
  
  ### Events
  
  def on_connect()
    server_puts "Connection from: #{addr}"
    sputs "Connection established #{Time.now.ctime}"
  end
  
  def on_input(str)
    #puts "#{addr} says: #{str}"
    if str.match(/^(disconnect)$/i)
      close
    elsif str.empty?
      # Do nothing
    else
      input_not_recognized(str)
    end
  end
  
  def on_close()
    sputs "Goodbye!"
    server_puts "#{addr} disconnected."
  end
end

class SocketServer
  attr_reader :port, :server
  def initialize(port)
    @port = port
    @server = TCPServer.open(@port)
    @connections = []
  end
  
  def run(connection_class=SocketConnection, &block)
    puts "Server is running on #{server.addr[2]}:#{port}"
    begin
      server_side = Thread.new do
        loop do
          on_input(gets)
        end
      end
      client_side = Thread.new do
        loop do
          Thread.start(server.accept) do |client|
            begin
              con = if block.nil?
                connection_class.new(client, self)
              else
                block.call(client, self)
              end
              unless con.nil?
                @connections << con
                con.run
              end
              clear_closed_connections
            rescue Exception => e
              puts "#{e} (#{e.class})"
              puts e.backtrace.map{|x| "  #{x}"}
            ensure
              client.close
              clear_closed_connections
            end
          end
        end
      end
      
      server_side.join
      client_side.join
    rescue Interrupt
      @connections.each &:close
      puts "Server shut down."
      exit
    end
  end
  
  private
  
  def clear_closed_connections()
    @connections.reject!{|c| c.closed?}
  end
  
  def on_input(str)
    case str.strip
    when /^list/
      puts "Connected users: " + @connections.map(&:to_s).sort!.join(", ")
    when /^exit/
      raise Interrupt.new
    else
      puts "Unknown command: #{str}"
    end
  end
end

if $0 == __FILE__
  SocketServer.new(2000).run
end
