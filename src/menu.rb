require_relative 'button'
require_relative 'constants'

class Menu
  def initialize
    @bg = Res.img(:other_bgStart)

    @buttons = {
      main: [
        Button.new(305, 240, :play),
        Button.new(305, 290, :instructions) do
          set_page(:instructions, 0)
        end,
        Button.new(305, 340, :options) do
          @state = :options
        end,
        Button.new(305, 390, :high_scores) do
          set_page(:high_scores, 0)
        end,
        Button.new(305, 480, :exit) do
          G.window.close
        end,
      ],
      instructions: [],
      options: [
        Button.new(100, 200, nil, false, '<') do
          Game.change_language(-1)
          @buttons.each { |_, group| group.each(&:update_text) }
        end,
        Button.new(SCREEN_WIDTH - 290, 200, nil, false, '>') do
          Game.change_language(1)
          @buttons.each { |_, group| group.each(&:update_text) }
        end,
        Button.new(100, 250, nil, false, '<') do
          Game.toggle_full_screen
        end,
        Button.new(SCREEN_WIDTH - 290, 250, nil, false, '>') do
          Game.toggle_full_screen
        end,
        Button.new(100, 300, nil, false, '<') do
          Game.change_music_volume(-1)
        end,
        Button.new(SCREEN_WIDTH - 290, 300, nil, false, '>') do
          Game.change_music_volume(1)
        end,
        Button.new(100, 350, nil, false, '<') do
          Game.change_sound_volume(-1)
        end,
        Button.new(SCREEN_WIDTH - 290, 350, nil, false, '>') do
          Game.change_sound_volume(1)
        end,
        Button.new(305, 510, :back, true) do
          @state = :main
        end
      ],
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
      @buttons[state] << Button.new(105, 510, :previous) do
        set_page(state, num - 1)
      end
    end
    @buttons[state] << Button.new(305, 510, :back, true) do
      @state = :main
    end
    if num < @page_count[state] - 1
      @buttons[state] << Button.new(505, 510, :next) do
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
    when :options
      @text_helper.write_line(Locl.text(:lang_name), SCREEN_WIDTH / 2, 215, :center, 0x003333)
      @text_helper.write_line(Locl.text(Game.full_screen ? :full_screen : :window), SCREEN_WIDTH / 2, 265, :center, 0x003333)
      @text_helper.write_line(Locl.text(:music_volume, Game.music_volume), SCREEN_WIDTH / 2, 315, :center, 0x003333)
      @text_helper.write_line(Locl.text(:sound_volume, Game.sound_volume), SCREEN_WIDTH / 2, 365, :center, 0x003333)
    end

    @buttons[@state]&.each(&:draw)
  end
end
