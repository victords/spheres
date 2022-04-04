require 'minigl'

class Lock < MiniGL::Sprite
  attr_accessor :stopped

  def initialize(x, y)
    super(x, y, :sprite_lock, 5, 1)
  end
end
