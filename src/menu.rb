require_relative 'button'
require_relative 'constants'

class Menu
  DIFFICULTIES = %i[easy normal hard expert]

  def initialize(state = :main)
    @bg = Res.img(:other_bgStart)

    @buttons = {
      main: [
        Button.new(305, 230, :play) do
          @state = :game_mode
        end,
        Button.new(305, 283, :instructions) do
          set_page(:instructions, 0)
        end,
        Button.new(305, 336, :options) do
          @state = :options
        end,
        Button.new(305, 389, :high_scores) do
          set_page(:high_scores, 0)
        end,
        Button.new(305, 480, :exit) do
          G.window.close
        end,
      ],
      instructions: [],
      options: [
        Button.new(80, 200, nil, false, '<') do
          Game.change_language(-1)
          @buttons.each { |_, group| group.each(&:update_text) }
        end,
        Button.new(SCREEN_WIDTH - 270, 200, nil, false, '>') do
          Game.change_language(1)
          @buttons.each { |_, group| group.each(&:update_text) }
        end,
        Button.new(80, 253, nil, false, '<') do
          Game.toggle_full_screen
        end,
        Button.new(SCREEN_WIDTH - 270, 253, nil, false, '>') do
          Game.toggle_full_screen
        end,
        Button.new(80, 306, nil, false, '<') do
          Game.change_music_volume(-1)
        end,
        Button.new(SCREEN_WIDTH - 270, 306, nil, false, '>') do
          Game.change_music_volume(1)
        end,
        Button.new(80, 359, nil, false, '<') do
          Game.change_sound_volume(-1)
        end,
        Button.new(SCREEN_WIDTH - 270, 359, nil, false, '>') do
          Game.change_sound_volume(1)
        end,
        Button.new(305, 510, :back, true) do
          Game.save_options
          @state = :main
        end
      ],
      high_scores: [],
      game_mode: [
        Button.new(305, 240, :basic) do
          Game.start_basic
        end,
        Button.new(305, 310, :dynamic) do
          @state = :dynamic_difficulty
        end,
        Button.new(305, 380, :static) do
          @state = :static_level
        end,
        Button.new(305, 480, :back, true) do
          @state = :main
        end
      ],
      dynamic_difficulty:
        DIFFICULTIES.map.with_index do |diff, i|
          Button.new(305, 240 + i * 53, diff) do
            Game.start_dynamic(diff)
          end
        end.push(
          Button.new(305, 480, :back, true) do
            @state = :game_mode
          end
        ),
      static_level:
        (0...Game.scores[5]).map do |i|
          Button.new((i % 4) * 194 + 14, (i / 4) * 53 + 230, nil, false, (i + 1).to_s) do
            Game.start_static(i + 1)
          end
        end.push(
          Button.new(305, 510, :back, true) do
            @state = :game_mode
          end
        )
    }

    @state = state
    @page_count = {
      instructions: 5,
      high_scores: 5
    }

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

    text_helper = Game.text_helper
    case @state
    when :instructions
      mode_page = @page > 0 && @page < 4
      text_helper.write_breaking(Locl.text("instructions_#{@page}".to_sym),
                                 mode_page ? 500 : SCREEN_WIDTH / 2, 200,
                                 mode_page ? 450 : 700,
                                 mode_page ? :right : :center,
                                 TEXT_COLOR)
      Res.img("other_screenshot#{@page}").draw(530, 200, 0) if mode_page
    when :options
      text_helper.write_line(Locl.text(:lang_name), SCREEN_WIDTH / 2, 215, :center, TEXT_COLOR)
      text_helper.write_line(Locl.text(Game.full_screen ? :full_screen : :window), SCREEN_WIDTH / 2, 268, :center, TEXT_COLOR)
      text_helper.write_line(Locl.text(:music_volume, Game.music_volume), SCREEN_WIDTH / 2, 321, :center, TEXT_COLOR)
      text_helper.write_line(Locl.text(:sound_volume, Game.sound_volume), SCREEN_WIDTH / 2, 374, :center, TEXT_COLOR)
    when :high_scores
      text = @page == 0 ? Locl.text(:high_scores_0) : Locl.text(:high_scores_1, Locl.text(DIFFICULTIES[@page - 1]))
      text_helper.write_line(text, SCREEN_WIDTH / 2, 175, :center, TEXT_COLOR)
      Game.scores[@page].each_with_index do |entry, i|
        text_helper.write_line("#{i + 1}. #{entry[0]}", 200, 210 + i * 28, :left, TEXT_COLOR)
        text_helper.write_line(entry[1], SCREEN_WIDTH - 200, 210 + i * 28, :right, TEXT_COLOR)
      end
    when :game_mode
      text_helper.write_line(Locl.text(:game_mode), SCREEN_WIDTH / 2, 180, :center, TEXT_COLOR)
    when :dynamic_difficulty
      text_helper.write_line(Locl.text(:difficulty), SCREEN_WIDTH / 2, 180, :center, TEXT_COLOR)
    when :static_level
      text_helper.write_line(Locl.text(:choose_level), SCREEN_WIDTH / 2, 180, :center, TEXT_COLOR)
    end

    @buttons[@state]&.each(&:draw)

    text_helper.write_line('v2.0.0', SCREEN_WIDTH - 10, SCREEN_HEIGHT - 20, :right, TEXT_COLOR, 255, nil, 0, 0, 0, 0, 0.5, 0.5)
  end
end
