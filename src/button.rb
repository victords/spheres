require 'minigl'

class Button < MiniGL::Button
  def initialize(x, y, text, back = false, &action)
    super(x: x, y: y, img: :interface_button)
    @_text = text
    @action = lambda do |_|
      action&.call
      Game.play_sound(back ? :backButtonClick : :buttonClick)
    end
    @text_helper = MiniGL::TextHelper.new(Game.font)
  end

  def draw
    super

    @text_helper.write_line(@_text, @text_x, @text_y - Game.font.height / 2, :center, 0xffffff, 255, :border, 0x006666, 2, 127)
  end
end
