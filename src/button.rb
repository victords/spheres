require 'minigl'

class Button < MiniGL::Button
  def initialize(x, y, text_id, back = false, text = nil, &action)
    super(x: x, y: y, img: :interface_button)
    @text_id = text_id
    @_text = text || Locl.text(text_id)
    @action = lambda do |_|
      action&.call
      Game.play_sound(back ? :backButtonClick : :buttonClick)
    end
  end

  def update_text(text_id = nil)
    @text_id = text_id if text_id
    return unless @text_id

    @_text = Locl.text(@text_id)
  end

  def draw(z_index = 0)
    super(255, z_index)

    Game.text_helper.write_line(@_text, @text_x, @text_y - Game.font.height / 2, :center, 0xffffff, @enabled ? 255 : 127, :border, 0x006666, 2, 127, z_index)
  end
end
