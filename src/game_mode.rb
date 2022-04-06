require_relative 'button'
require_relative 'constants'
require_relative 'sphere'
require_relative 'lock'
require_relative 'match'

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
    @margin = Vector.new((SCREEN_WIDTH - SPHERE_SIZE * NUM_COLS) / 2, 95)
    @cursor = MiniGL::Sprite.new(0, 0, :interface_cursor)

    start
  end

  def start
    @paused = false
    @buttons[0].update_text(:pause)
    @confirmation = nil

    @objects = Array.new(NUM_COLS) do
      Array.new(NUM_ROWS)
    end
    @level = 1
    @score = 0
    @matches = []
    @match_count = 0
  end

  def add_sphere(col, row, type, locked = false, ceiling = false)
    y = @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE
    y -= SPHERE_SIZE if ceiling
    @objects[col][row] = Sphere.new(type, locked, @margin.x + col * SPHERE_SIZE, y)
  end

  def add_lock(col, row)
    @objects[col][row] = Lock.new(@margin.x + col * SPHERE_SIZE, @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE)
  end

  def can_move?(sphere, col, row, row_y)
    obj_below = row > 0 && @objects[col][row - 1]
    sphere&.stopped && sphere.y == row_y && !sphere.locked && (!obj_below || obj_below.y == row_y + SPHERE_SIZE)
  end

  def check_matches(horizontal = true)
    limit1 = horizontal ? NUM_ROWS : NUM_COLS
    limit2 = horizontal ? NUM_COLS : NUM_ROWS

    matches = []
    (0...limit1).each do |i|
      (0...limit2).each do |j|
        col = horizontal ? j : i
        row = horizontal ? i : j
        obj = @objects[col][row]
        unless obj.is_a?(Sphere) && obj.stopped
          matches << nil
          next
        end

        match = matches[-1]
        same_line = match && (horizontal ? row == match.row : col == match.col)
        if same_line && (obj.type == match.type || obj.type == :rainbow || match.type == :rainbow)
          match.type = obj.type if obj.type != :rainbow
          match.chain = obj.chain if obj.chain > match.chain
          match.count += 1
        else
          matches << Match.new(obj.type, horizontal, col, row, obj.chain)
        end
      end
    end
    matches
  end

  def check_level_up
    return unless @match_count >= @matches_to_level_up

    @match_count -= @matches_to_level_up
    @level += 1
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE + (@level - 1) * MATCHES_TO_LEVEL_UP_INCR
    @spawn_interval = [SPAWN_INTERVAL_BASE - (@level - 1) * SPAWN_INTERVAL_DECR, SPAWN_INTERVAL_MIN].max
  end

  def update
    if @confirmation
      @confirm_buttons.each(&:update)
      return
    end

    @buttons.each(&:update)

    # update existing matches
    @matches.reverse_each do |m|
      m.update(@objects)
      @matches.delete(m) if m.dead?
    end

    if @matches.empty?
      # falling movement
      (0...NUM_ROWS).each do |j|
        (0...NUM_COLS).each do |i|
          obj = @objects[i][j]
          next if obj.nil?

          obj.stopped = true
          next if j == 0 && obj.y == @margin.y + (NUM_ROWS - 1) * SPHERE_SIZE ||
                  j > 0 && @objects[i][j - 1]&.y == obj.y + SPHERE_SIZE

          obj.y += FALL_SPEED
          obj.stopped = false
          if obj.y > @margin.y + (NUM_ROWS - j - 1) * SPHERE_SIZE
            @objects[i][j - 1] = obj
            @objects[i][j] = nil
          end
        end
      end

      # check new matches
      matches = check_matches
      matches += check_matches(false)
      @matches = matches.compact.select { |m| m.count >= 3 }
      @matches.each do |m|
        m.startup(@objects)
        @score += m.score
      end
      @match_count += @matches.count

      # break chain
      @objects.flatten.select { |o| o.is_a?(Sphere) }.each do |s|
        s.unchain! if s.stopped
      end
    end

    return unless game_cursor?

    # player action
    col = (Mouse.x - @margin.x) / SPHERE_SIZE
    col = NUM_COLS - 2 if col >= NUM_COLS - 1
    mouse_row = (Mouse.y - @margin.y) / SPHERE_SIZE
    row_y = @margin.y + mouse_row * SPHERE_SIZE
    @cursor.x = @margin.x + col * SPHERE_SIZE
    @cursor.y = row_y
    return unless Mouse.button_pressed?(:left)

    row = NUM_ROWS - mouse_row - 1
    o1 = @objects[col][row]
    o2 = @objects[col + 1][row]
    return if o1.is_a?(Lock) || o2.is_a?(Lock)

    if o1
      if o2
        if can_move?(o1, col + 1, row, row_y) && can_move?(o2, col, row, row_y)
          o1.x += SPHERE_SIZE
          o2.x -= SPHERE_SIZE
          @objects[col][row] = o2
          @objects[col + 1][row] = o1
        end
      elsif can_move?(o1, col + 1, row, row_y)
        o1.x += SPHERE_SIZE
        @objects[col][row] = nil
        @objects[col + 1][row] = o1
      end
    elsif can_move?(o2, col, row, row_y)
      o2.x -= SPHERE_SIZE
      @objects[col][row] = o2
      @objects[col + 1][row] = nil
    end
  end

  def game_cursor?
    @confirmation.nil? &&
      Mouse.x >= @margin.x && Mouse.x < @margin.x + NUM_COLS * SPHERE_SIZE &&
      Mouse.y >= @margin.y && Mouse.y < @margin.y + NUM_ROWS * SPHERE_SIZE
  end

  def draw
    @bg.draw(235, 90, 0)

    @objects.flatten.each { |s| s&.draw }
    @matches.each { |m| m.draw(@margin) }
    @cursor.draw if game_cursor?

    @fg.draw(0, 0, 0)
    Game.text_helper.write_line(Locl.text(:level, @level), 10, 105, :left, TEXT_COLOR)
    Game.text_helper.write_line(Locl.text(:score, @score), 10, 175, :left, TEXT_COLOR)
    @buttons.each(&:draw)

    if @confirmation
      G.window.draw_quad(0, 0, 0x80000000,
                         SCREEN_WIDTH, 0, 0x80000000,
                         0, SCREEN_HEIGHT, 0x80000000,
                         SCREEN_WIDTH, SCREEN_HEIGHT, 0x80000000, 0)
      @dialog.draw((SCREEN_WIDTH - @dialog.width) / 2, (SCREEN_HEIGHT - @dialog.height) / 2, 0)
      Game.text_helper.write_line(Locl.text(:are_you_sure, Locl.text(@confirmation).downcase),
                                  SCREEN_WIDTH / 2,
                                  (SCREEN_HEIGHT - @dialog.height) / 2 + 65,
                                  :center,
                                  TEXT_COLOR)
      @confirm_buttons.each(&:draw)
    end
  end
end
