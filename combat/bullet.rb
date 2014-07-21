
module Combat

  class Bullet

    attr_reader :x, :y

    def initialize(window, x, y, angle, scale)
    
      @window = window
      @age = 0
      @x, @y, @angle = x, y, angle
      @birth = @window.ticks
      @scale = scale
    
    end
    
    def update
      move
    end
    
    def draw
      @window.draw_quad(
        (@x-1)*@scale, (@y-1)*@scale, Gosu::Color::BLUE,
        (@x+1)*@scale, (@y-1)*@scale, Gosu::Color::BLUE,
        (@x-1)*@scale, (@y+1)*@scale, Gosu::Color::BLUE,
        (@x+1)*@scale, (@y+1)*@scale, Gosu::Color::BLUE,
        1)
    end
    
    def move
      @x += Gosu::offset_x(@angle-90, 3*@scale)
      @y += Gosu::offset_y(@angle-90, 3*@scale)
    end
    
    def age
      @age = @window.ticks - @birth
    end
    
    def destroy_tanks(tanks, owner)
      tanks.reject! {|tank|
        Gosu::distance(@x, @y, tank.x, tank.y) < 6 and tank != owner
          
      }
    end
  end

end