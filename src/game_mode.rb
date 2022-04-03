require_relative 'button'
require_relative 'constants'

class GameMode
  def initialize
    @bg = Res.img(:other_bgMain)
    @fg = Res.img(:other_fgMain)
    @buttons = [
      Button.new(585, 95, :pause) do
        @paused = !@paused
        @buttons[0].update_text(@paused ? :resume : :pause)
      end,
      Button.new(585, 148, :restart) do
        @confirmation = :restart
      end,
      Button.new(585, 201, :exit) do
        @confirmation = :exit
      end,
    ]

    @dialog = Res.img(:interface_confirmDialog)
    @confirm_buttons = [
      Button.new(190, 330, :yes) do
        if @confirmation == :restart
          start
        else
          Game.quit
        end
      end,
      Button.new(420, 330, :no, true) do
        @confirmation = nil
      end,
    ]

    @text_helper = TextHelper.new(Game.font)
  end

  def start
    @paused = false
    @buttons[0].update_text(:pause)
    @confirmation = nil
  end

  def update
    if @confirmation
      @confirm_buttons.each(&:update)
      return
    end

    @buttons.each(&:update)
  end

  def draw
    @bg.draw(235, 90, 0)
    yield if block_given?
    @fg.draw(0, 0, 0)
    @buttons.each(&:draw)

    if @confirmation
      G.window.draw_quad(0, 0, 0x80000000,
                         SCREEN_WIDTH, 0, 0x80000000,
                         0, SCREEN_HEIGHT, 0x80000000,
                         SCREEN_WIDTH, SCREEN_HEIGHT, 0x80000000, 0)
      @dialog.draw((SCREEN_WIDTH - @dialog.width) / 2, (SCREEN_HEIGHT - @dialog.height) / 2, 0)
      @text_helper.write_line(Locl.text(:are_you_sure, Locl.text(@confirmation).downcase),
                              SCREEN_WIDTH / 2,
                              (SCREEN_HEIGHT - @dialog.height) / 2 + 65,
                              :center,
                              TEXT_COLOR)
      @confirm_buttons.each(&:draw)
    end
  end
end
