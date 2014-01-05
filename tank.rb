
class Tank

  attr_reader :bullets, :x, :y, :instruction_set, :desc, :mutate
  attr_accessor :kills
  
  def initialize(
      window,
      color = Gosu::Color.new(255, 255, 255, 255),
      instructions = ([:fire]*rand(5) + [:turn_right]*rand(20) + [:turn_left]*rand(2) + [:move]*rand(40)).shuffle!,
      desc = 0,
      mutate = 0.75,
      fertility_rate = 0.006)
    
    @image = Gosu::Image.new(window, "tank.bmp", true).retro!

    @x, @y = (rand(1500))%window.width, (rand(1500))%window.height
    @angle = 22.5*rand(16)
    @window = window
    @moving = false
    @bullets = []
    @kills = 0
    @age = 0
    @life_expectancy = 15000
    @birth_date = Gosu::milliseconds
    @instruction_set = instructions
    !(instructions.empty?) ? @instructions = instructions.cycle : @instructions = []
    @desc = desc
    @color = color
    @cooldown = 0
    @last = Gosu::milliseconds
    @mutate = mutate
    @fertility = fertility_rate
    @scale = @window.scale
    
  end
  
  def update
    wander
    @bullets.each do |bullet|
      bullet.update
    end
    @bullets.reject! {|bullet| bullet.age > 20 }
  end
  
  def fire
    @cooldown -= Gosu::milliseconds - @last
    @last = Gosu::milliseconds
    if @cooldown <= 0
      make_new_bullet
    end
  end
  
  def draw
    @image.draw_rot(@x, @y, 0, @angle, 0.5, 0.5, @scale, @scale, @color)
  end
  
  def get_hit
  
  end
  
  def age_in_seconds
    age/1000
  end
  
  def wander
    #return :dead if age > 15
    self.send(@instructions.next) unless @instructions == []
    replication
  end
  
  def replication
    color = @color.dup
    red = color.red - 5 + 10*rand
    green = color.green - 5 + 10*rand
    blue = color.blue - 5 + 10*rand
    mutate = 1-((1-@mutate)*(0.95+rand/10))
    if rand < @fertility
      @window.tanks << Tank.new(@window, Gosu::Color.new(255, red, green, blue), descent_with_modification, @desc + 1, mutate)
    end
  end

  def turn_right
    @angle += 22.5
    @angle = (@angle*2 % 720)/2
  end
  
  def turn_left
    @angle -= 22.5
    @angle = (@angle*2 % 720)/2
  end
  
  def move
    @x += Gosu::offset_x(@angle-90, 3*@scale)
    @y += Gosu::offset_y(@angle-90, 3*@scale)
    @x %= @window.width
    @y %= @window.height
  end
  
  def make_new_bullet
    #bullet = Bullet.new(@window, @x, @y, @angle)
    #@window.cells.each do |cell|
    #  if bullet.x
    @bullets << Bullet.new(@window, @x, @y, @angle, @scale)
    @cooldown = 500
  end
  
  def descent_with_modification
  
    instruction = @instruction_set.dup
    #[->{instruction << :move} => @variation[0],
    # ->{instruction << :fire} => @variation[1],
    # ->{instruction << :turn} => @variation[2],
    # ->{instruction.pop unless instruction.size == 1} => @variation[3]
    #].sample.call
    [->{instruction << :move},
     ->{instruction << :fire},
     ->{instruction << :turn_right},
     ->{instruction << :turn_left},
     ->{instruction.delete_at(rand(instruction.length))}
    ].sample.call if rand > @mutate
    
    instruction[rand(instruction.length)] = [:move, :fire, :turn_right, :turn_left].sample if rand > @mutate
    
    #rand > 0.5 ? (instruction << :move) : (instruction.pop if ((instruction.length > 1) and (rand > 0.6)))
    #rand > 0.5 ? (instruction << [:move, :turn, :fire].sample) : (instruction.pop if instruction.length > 1)
    instruction#.shuffle
  
  end
  
  def age
    Gosu::milliseconds - @birth_date
  end
  
end