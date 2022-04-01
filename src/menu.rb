require_relative 'button'
require_relative 'constants'

class Menu
  def initialize
    @bg = Res.img(:other_bgStart)

    @buttons = {
      main: [
        Button.new(305, 240, Locl.text(:play)),
        Button.new(305, 290, Locl.text(:instructions)) do
          set_page(:instructions, 0)
        end,
        Button.new(305, 340, Locl.text(:options)),
        Button.new(305, 390, Locl.text(:high_scores)) do
          set_page(:high_scores, 0)
        end,
        Button.new(305, 480, Locl.text(:exit)) do
          G.window.close
        end,
      ],
      instructions: [],
      options: [],
      high_scores: []
    }

    @state = :main
    @page_count = {
      instructions: 5,
      high_scores: 5
    }

    @text_helper = TextHelper.new(Game.font)

    Game.play_song(:spheresTheme)
  end

  def set_page(state, num)
    @state = state
    @page = num
    @buttons[state].clear
    if num > 0
      @buttons[state] << Button.new(105, 510, Locl.text(:previous)) do
        set_page(state, num - 1)
      end
    end
    @buttons[state] << Button.new(305, 510, Locl.text(:back)) do
      @state = :main
    end
    if num < @page_count[state] - 1
      @buttons[state] << Button.new(505, 510, Locl.text(:next)) do
        set_page(state, num + 1)
      end
    end
  end

  def update
    @buttons[@state]&.each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)

    case @state
    when :instructions
      mode_page = @page > 0 && @page < 4
      @text_helper.write_breaking(Locl.text("instructions_#{@page}".to_sym),
                                  mode_page ? 500 : SCREEN_WIDTH / 2, 200,
                                  mode_page ? 450 : 700,
                                  mode_page ? :right : :center,
                                  0x003333)
      Res.img("other_screenshot#{@page}").draw(530, 200, 0) if mode_page
    end

    @buttons[@state]&.each(&:draw)
  end
end
