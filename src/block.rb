require 'minigl'

class Block < MiniGL::Sprite
  def initialize(x, y)
    super(x, y, :sprite_block)
  end
end
