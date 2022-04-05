require 'minigl'

class Sphere < MiniGL::Sprite
  attr_reader :type, :chain
  attr_accessor :stopped

  def initialize(type, locked, x, y)
    super(x, y, "sprite_#{type}Sphere", 2, 1)
    @type = type
    @lock = Res.img(:sprite_cage) if locked
    @chain = 0
  end

  def locked
    @lock
  end

  def chain!(value)
    @chain = value
    @stopped = false
  end

  def unchain!
    @chain = 0
  end

  def draw
    super
    @lock&.draw(@x, @y, 0)
    Game.font.draw_text(@chain.to_s, @x, @y, 0)
  end
end
