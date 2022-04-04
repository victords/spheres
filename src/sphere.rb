class Sphere
  attr_accessor :x, :y, :stopped

  def initialize(type, locked, x, y)
    @type = type
    @img = Res.imgs("sprite_#{type}Sphere", 2, 1)
    @lock = Res.img(:sprite_cage) if locked
    @x = x
    @y = y
  end

  def locked
    @lock
  end

  def draw
    @img[0].draw(@x, @y, 0)
    @lock&.draw(@x, @y, 0)
  end
end
