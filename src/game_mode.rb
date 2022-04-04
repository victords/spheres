require_relative 'button'
require_relative 'constants'
require_relative 'sphere'

class GameMode
  NUM_COLS = 8
  NUM_ROWS = 12

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

    @spheres = Array.new(NUM_COLS) do
      Array.new(NUM_ROWS)
    end
    @margin = Vector.new((SCREEN_WIDTH - SPHERE_SIZE * NUM_COLS) / 2, 95)

    @cursor = MiniGL::Sprite.new(0, 0, :interface_cursor)
  end

  def start
    @paused = false
    @buttons[0].update_text(:pause)
    @confirmation = nil
  end

  def add_sphere(col, row, type, locked = false)
    @spheres[col][row] = Sphere.new(type, locked, @margin.x + col * SPHERE_SIZE, @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE)
  end

  def update
    if @confirmation
      @confirm_buttons.each(&:update)
      return
    end

    @buttons.each(&:update)

    (0...NUM_COLS).each do |i|
      (0...NUM_ROWS).each do |j|
        next if !@spheres[i][j] || @spheres[i][j - 1]&.y == @spheres[i][j].y + SPHERE_SIZE
        next if j == 0 && @spheres[i][j].y == @margin.y + (NUM_ROWS - 1) * SPHERE_SIZE

        @spheres[i][j].y += FALL_SPEED
        if @spheres[i][j].y > @margin.y + (NUM_ROWS - j - 1) * SPHERE_SIZE
          @spheres[i][j - 1] = @spheres[i][j]
          @spheres[i][j] = nil
        end
      end
    end

    return unless game_cursor?

    col = (Mouse.x - @margin.x) / SPHERE_SIZE
    col = NUM_COLS - 2 if col >= NUM_COLS - 1
    mouse_row = (Mouse.y - @margin.y) / SPHERE_SIZE
    row = NUM_ROWS - mouse_row - 1
    row_y = @margin.y + mouse_row * SPHERE_SIZE
    @cursor.x = @margin.x + col * SPHERE_SIZE
    @cursor.y = row_y
    if Mouse.button_pressed?(:left)
      s1 = @spheres[col][row]
      s2 = @spheres[col + 1][row]
      if s1
        if s2
          if s1.y == row_y && s2.y == row_y
            s1.x += SPHERE_SIZE
            s2.x -= SPHERE_SIZE
            @spheres[col][row] = s2
            @spheres[col + 1][row] = s1
          end
        elsif s1.y == row_y
          s1.x += SPHERE_SIZE
          @spheres[col][row] = nil
          @spheres[col + 1][row] = s1
        end
      elsif s2 && s2.y == row_y
        s2.x -= SPHERE_SIZE
        @spheres[col][row] = s2
        @spheres[col + 1][row] = nil
      end
    end
  end

  def game_cursor?
    @confirmation.nil? &&
      Mouse.x >= @margin.x && Mouse.x < @margin.x + NUM_COLS * SPHERE_SIZE &&
      Mouse.y >= @margin.y && Mouse.y < @margin.y + NUM_ROWS * SPHERE_SIZE
  end

  def draw
    @bg.draw(235, 90, 0)

    @spheres.flatten.each { |s| s&.draw }
    @cursor.draw if game_cursor?

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
