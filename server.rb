require 'gserver'

class NardsServer < GServer
  def initialize *args
    super
    @gamers = Hash.new
    @msg = []
    @msg[0], @msg[1], @msg[2] = "msg[0]", "hello", "hello"
  end

  def disconnecting(clientPort)
    log("#{self.class.to_s} #{@host}:#{@port} " +
            "client:#{clientPort} disconnect")
    @gamers.each{|key, value| @gamers.delete(key) if value.peeraddr(true)[1] == clientPort}
    log("#{@gamers}")
  end

  def serve io
    unless @gamers.has_value?(io)
      if !@gamers.has_key?("1")
        @gamers["1"] = io.clone
        next_side = 1
      elsif !@gamers.has_key?("2")
        @gamers["2"] = io.clone
        next_side = 2
      else
        next_side = 0
      end
    end
    loop{
      cmd, *arg = *io.gets.chomp.split
      case cmd
        when "get_side"
          begin
          io.puts "#{next_side}"
          end
        when "move_selected_to_position"
          begin
            if arg[0].to_i == 1
              to_side = 2
            else
              if arg[0].to_i == 2
                to_side = 1
              else
                to_side = 0
              end
            end
            @msg[to_side] = "move_selected_to_position #{arg[1]} #{arg[2]} #{arg[3]}"
            io.puts "+OK"
          end
        when "get_message"
          begin
              io.puts "#{@msg[arg[0].to_i]}"
              @msg[arg[0].to_i] = "hello"
          end
        when "shutdown"
          begin
          io.puts "+OK"
          io.close
          end
      end
      io.puts "+OK"
    }
  end
end

NardsServer.new(7000, 'localhost', 2, $stderr, true).start.join
