Dir.chdir(File.dirname(__FILE__))

require 'gosu'
require 'opengl'

class Gosu::Image

  def retro!
    
    glBindTexture(GL_TEXTURE_2D, self.gl_tex_info.tex_name)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    
    self
  
  end
  
end

require_relative 'lib/tank.rb'
require_relative 'lib/bullet.rb'
require_relative 'lib/cell.rb'

class Combat < Gosu::Window

  WIDTH = 640
  HEIGHT = 480
  CELLWIDTH = 50
  CELLHEIGHT = 50
  BackgroundColor = Gosu::Color.new(255, 175, 185, 85)
  attr_accessor :tanks
  attr_reader :ticks, :scale

  def initialize
  
    super WIDTH, HEIGHT, false
    self.caption = "Combat!"
    
    @logo_font = Gosu::Font.new(self, Gosu::default_font_name, 100)
    @menu_font = Gosu::Font.new(self, Gosu::default_font_name, 30)
    @pause_font = Gosu::Font.new(self, Gosu::default_font_name, 40)
    
    @scale = 1
    @tanks = []
    10.times do |i|
      make_new_tank(Gosu::Color.new(255, rand(0..255), rand(0..255), rand(0..255)))
    end
    
    @experiment_initial_time = Gosu::milliseconds
    @ticks = 0
    @cells = []
    
    (0..HEIGHT/CELLHEIGHT).each do |y|
      (0..WIDTH/CELLWIDTH).each do |x|
        @cells << Cell.new(CELLWIDTH*x, CELLHEIGHT*y)
      end
    end
    
    @paused = false
    @menu = true
    @menu_position = 0
  
  end
  
  def update
    
    unless @paused || @menu
    
      @tanks.each do |tank|
        tank.kills += 1 if kill_tanks(tank)
        tank.update
      end
      
    end
    
    @ticks+=1
  
  end
  
  def draw
  
    case
    when @menu   then menu_screen
    when @paused then pause_screen
    else
      draw_background
      draw_tanks
    end
    
  end
  
  def pause
    @paused = !@paused
  end
  
  def button_down id
  
    if @menu
      case id
      when Gosu::KbDown then toggle_menu_position
      when Gosu::KbUp   then toggle_menu_position
      when Gosu::KbReturn
        @menu_position == 0 ? @menu = false : close
      when Gosu::KbEscape then close
      else
      end
    else
      case id
      when Gosu::KbE      then monitor
      when Gosu::KbP      then pause
      when Gosu::KbR      then restart
      when Gosu::KbNumpadAdd
        @scale += 1 if @scale < 5
      when Gosu::KbNumpadSubtract
        @scale -= 1 if @scale > 1
      when Gosu::KbSpace  then 5.times {make_new_tank(random_color)}
      when Gosu::KbEscape then @menu = true
      end
    end
  end
  
  private
  
  def restart
    @scale = 1
    @tanks = []
    10.times do |i|
      make_new_tank(Gosu::Color.new(255, rand(0..255), rand(0..255), rand(0..255)))
    end
    
    @experiment_initial_time = Gosu::milliseconds
    @ticks = 0
    
  end
  
  def toggle_menu_position
    @menu_position = (@menu_position + 1) % 2
  end
  
  def make_new_tank(color)
    @tanks << Tank.new(self, color)
  end
  
  def random_color
    Gosu::Color.new(255, 200-150*rand, 200-150*rand, 200-150*rand)#rand(0..255), rand(0..255), rand(0..255))
  end
  
  def kill_tanks(tank)
    tank.bullets.reject! {|bullet| bullet.destroy_tanks(@tanks, tank)}
  end
  
  def monitor
    puts "------------------------------------------------------------------------"
    puts
    puts "Experiment has run for #{experiment_duration(:in_seconds)} seconds."
    puts
    puts @tanks.size.to_s + " Tanks on the screen"
    puts
    @youngest_tank = @oldest_tank = @highest_kill_tank = @tanks[0]
    @tanks.each do |tank|
      @highest_kill_tank = tank if tank.kills > @highest_kill_tank.kills
      @oldest_tank = tank if tank.age > @oldest_tank.age
      @youngest_tank = tank if tank.age < @youngest_tank.age
    end
    puts "Oldest tank:"
    puts "  Age: #{@oldest_tank.age_in_seconds} seconds"
    puts "  Kills: #{@oldest_tank.kills}"
    puts "  Instruction set: #{@oldest_tank.instruction_set}"
    puts "  Generation: #{@oldest_tank.desc}"
    puts "  Mutation Chance: #{(1-@oldest_tank.mutate)*100}%"
    puts
    puts "Youngest tank:"
    puts "  Age: #{@youngest_tank.age_in_seconds} seconds"
    puts "  Kills: #{@youngest_tank.kills}"
    puts "  Instruction set: #{@youngest_tank.instruction_set}"
    puts "  Generation: #{@youngest_tank.desc}"
    puts "  Mutation Chance: #{(1-@youngest_tank.mutate)*100}%"
    puts
    puts "Bloodiest tank:"
    puts "  Age: #{@highest_kill_tank.age_in_seconds} seconds"
    puts "  Kills: #{@highest_kill_tank.kills}"
    puts "  Instruction set: #{@highest_kill_tank.instruction_set}"
    puts "  Generation: #{@highest_kill_tank.desc}"
    puts "  Mutation Chance: #{(1-@highest_kill_tank.mutate)*100}%"
    puts
    puts
  
  end
  
  def experiment_duration(mode = :in_milliseconds)
  
    time = Gosu::milliseconds - @experiment_initial_time
    case mode
    when :in_seconds
      time/1000
    else
      time
    end
    
  end
  
  def draw_background
  
    draw_quad(
    0,     0,      BackgroundColor,
    WIDTH, 0,      BackgroundColor,
    0,     HEIGHT, BackgroundColor,
    WIDTH, HEIGHT, BackgroundColor,
    -1)
    
  end
  
  def draw_tanks
  
    @tanks.each do |tank|
      tank.draw
      tank.bullets.each do |bullet|
        bullet.draw
      end
    end

  end
  
  def pause_screen
    #pause screen logic
    
    #draw main game
    draw_background
    draw_tanks
    
    #"dim" main game
    draw_quad(
    0,     0,      Gosu::Color.new(160, 0, 0, 0),
    WIDTH, 0,      Gosu::Color.new(160, 0, 0, 0),
    0,     HEIGHT, Gosu::Color.new(160, 0, 0, 0),
    WIDTH, HEIGHT, Gosu::Color.new(160, 0, 0, 0),
    1)
    
    #display PAUSED in big letters in the center of the screen
    string = "PAUSED"
    @pause_font.draw(
      string,
      WIDTH/2-@pause_font.text_width(string)/2,
      HEIGHT/2-@pause_font.height/2,
      2,
      1,
      1,
      0xffffffff
    )
  end
  
  def menu_screen
    string = "COMBAT!"
    @logo_font.draw(
      string,
      WIDTH/2-@logo_font.text_width(string)/2,
      HEIGHT/2-@logo_font.height/2-100,
      0,
      1,
      1,
      0xffffffff
    )
    string = "Start Game"
    @menu_font.draw(
      string,
      WIDTH/2-@menu_font.text_width(string)/2,
      HEIGHT/2-@menu_font.height/2 + 25,
      0,
      1,
      1,
      0xffffffff
    )
    string = "Exit"
    @menu_font.draw(
      string,
      WIDTH/2-@menu_font.text_width(string)/2-45,
      HEIGHT/2-@menu_font.height/2 + @menu_font.height + 25,
      0,
      1,
      1,
      0xffffffff
    )
    string = "->"
    @menu_font.draw(
      string,
      WIDTH/2-@menu_font.text_width(string)/2-100 + 3*Math.sin(@ticks/15.0),
      HEIGHT/2-@menu_font.height/2 + @menu_font.height*@menu_position + 25,
      0,
      1,
      1,
      0xffffffff
    )
  
  end
  
end

Combat.new.show
