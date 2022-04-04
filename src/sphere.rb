require 'minigl'

class Sphere < MiniGL::Sprite
  attr_reader :type
  attr_accessor :stopped

  def initialize(type, locked, x, y)
    super(x, y, "sprite_#{type}Sphere", 2, 1)
    @type = type
    @lock = Res.img(:sprite_cage) if locked
  end

  def locked
    @lock
  end

  def draw
    super
    @lock&.draw(@x, @y, 0)
  end
end
