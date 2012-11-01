require 'gserver'

class NardsServer < GServer
  def initialize *args
    super
    @gamers = []
    @next_side ||= 1
    @msg = []
    @msg[0], @msg[1], @msg[2] = "msg[0]", "hello", "hello"
  end

  def disconnecting(clientPort)
    log("#{self.class.to_s} #{@host}:#{@port} " +
            "client:#{clientPort} disconnect")
    @gamers.each{
      |gamer|
      unless gamer == clientPort
        @gamers.delete clientPort
      end
      if @next_side == 0 && @gamers.count == 0
        @next_side = 1
      end
    }
  end

  def serve io
    @gamers << io
    loop{
      cmd, *arg = *io.gets.chomp.split
      case cmd
        when "get_side"
          begin
          io.puts "#{@next_side}"
          if @next_side == 1
            @next_side = @next_side + 1
          else
            @next_side = 0
          end
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
