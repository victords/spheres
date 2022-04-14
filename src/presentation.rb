class Presentation
  AUTHOR_NAME = 'Victor David Santos'

  def initialize
    @logo = Res.img(:other_minigl)
    @timer = 0

    Game.play_song(:spheresTheme)
  end

  def update
    @timer += 1
    Game.show_menu if @timer == 440 || Mouse.button_pressed?(:left)
  end

  def draw
    if @timer <= 220
      t = [110, @timer].min
      w = @logo.width / 2
      x = (-w + (t / 110.0) * (SCREEN_WIDTH / 2 + w)).round
      alpha = @timer <= 190 ? 255 : 255 - (((@timer - 190) / 30.0) * 255).round
      @logo.draw(x - w, (SCREEN_HEIGHT - @logo.height) / 2, 0, 1, 1, (alpha << 24) | 0xffffff)
      Game.text_helper.write_line(Locl.text(:powered_by), x, (SCREEN_HEIGHT - @logo.height) / 2 - 40, :center, 0xffffff, alpha)
    else
      t = [110, @timer - 220].min
      w = Game.font.text_width(AUTHOR_NAME) * 1.5 / 2
      x = (SCREEN_WIDTH + w - (t / 110.0) * (SCREEN_WIDTH / 2 + w)).round
      Game.text_helper.write_line(Locl.text(:game_by), x, SCREEN_HEIGHT / 2 - 40, :center, 0xffffff)
      Game.text_helper.write_line(AUTHOR_NAME, x, SCREEN_HEIGHT / 2 - 10, :center, 0xffffff, 255, nil, 0, 0, 0, 0, 1.5, 1.5)
    end
  end
end
