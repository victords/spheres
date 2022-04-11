class TextEffect
  def initialize(x, y, text, duration = 90)
    @x = x
    @y = y
    @text = text
    @duration = duration
    @alpha = 255
  end

  def dead?
    @duration <= 0
  end

  def update
    @y -= 1
    @duration -= 1
    if @duration < 30
      @alpha = ((@duration / 30.0) * 255).round
    end
  end

  def draw
    Game.text_helper.write_line(@text, @x, @y, :center, 0xffffff, @alpha, :border, 0x006666, 2, @alpha / 2, 1, 1.5, 1.5)
  end
end
