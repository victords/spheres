require_relative 'constants'
require_relative 'game_mode'

class StaticMode < GameMode
  def initialize(level)
    @num = level
    super()
  end

  def start
    super
    @level = @num

    File.open("#{Res.prefix}levels/#{@num}") do |f|
      f.each.with_index do |line, j|
        if j == 0
          @min_score = line.to_i
          next
        end

        row = NUM_ROWS - j
        line.chomp.each_char.with_index do |c, col|
          next if c == '.'

          case c
          when 'r'
            add_sphere(col, row, :red)
          when 'g'
            add_sphere(col, row, :green)
          when 'b'
            add_sphere(col, row, :blue)
          when 'c'
            add_sphere(col, row, :cyan)
          when 'm'
            add_sphere(col, row, :magenta)
          when 'y'
            add_sphere(col, row, :yellow)
          when 'R'
            add_sphere(col, row, :red, true)
          when 'G'
            add_sphere(col, row, :green, true)
          when 'B'
            add_sphere(col, row, :blue, true)
          when 'C'
            add_sphere(col, row, :cyan, true)
          when 'M'
            add_sphere(col, row, :magenta, true)
          when 'Y'
            add_sphere(col, row, :yellow, true)
          when '*'
            add_sphere(col, row, :rainbow)
          when '#'
            @objects[col][row] = Block.new(@margin.x + col * SPHERE_SIZE, @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE)
          end
        end
      end
    end
  end

  def update
    if @completed
      @effects.reverse_each do |e|
        e.update
        @effects.delete(e) if e.dead?
      end

      @timer -= 1
      if @timer == 0
        if @completed == :level
          if @num < TOTAL_STATIC_LEVELS
            Game.start_static(@num + 1)
          else
            @completed = :all
            @timer = 120
          end
        else
          Game.show_menu(true)
        end
      end
      return
    end

    super
    return if @confirmation || @game_over || @paused || @matches.any?

    if @min_score > 0 && @score >= @min_score ||
      @min_score == 0 && !@objects.flatten.any? { |o| o.is_a?(Sphere) }
      @completed = :level
      @timer = 120
    end
  end

  def game_cursor?
    super && !@completed
  end

  def draw
    super

    if @min_score > 0
      Game.text_helper.write_breaking(Locl.text(:min_score, @min_score), 10, 245, 200, :left, TEXT_COLOR)
    else
      Game.text_helper.write_breaking(Locl.text(:clear_all), 10, 245, 200, :left, TEXT_COLOR)
    end

    if @completed
      text_id = @completed == :level ? :completed : :all_completed
      Game.text_helper.write_line(Locl.text(text_id), SCREEN_WIDTH / 2, 300, :center, 0xffffff, 255, :border, 0x006666, 2, 127, 1, 1.5, 1.5)
    end
  end
end
