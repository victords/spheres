require_relative 'button'
require_relative 'constants'
require_relative 'sphere'
require_relative 'lock'
require_relative 'match'
require_relative 'text_effect'

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
        if @game_over
          start
        else
          @confirmation = :restart
        end
      end,
      Button.new(585, 201, :exit) do
        if @game_over
          Game.quit
        else
          @confirmation = :exit
        end
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

    @txt_name = MiniGL::TextField.new(
      x: 225,
      y: 280,
      font: Game.font,
      img: :interface_textField,
      cursor_img: :interface_textCursor,
      margin_x: 10,
      margin_y: 10,
      max_length: 15,
      allowed_chars: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%&*()-_=+./? ',
      text_color: TEXT_COLOR
    )
    @high_score_button = Button.new(305, 330, :ok) do
      if @txt_name.text.empty?
        @txt_name.focus
        next
      end
      Game.add_score(@high_scores_table_index, @high_scores_rank, @txt_name.text, @score)
      @game_over = :high_scores
    end

    @margin = Vector.new((SCREEN_WIDTH - SPHERE_SIZE * NUM_COLS) / 2, 95)
    @cursor = MiniGL::Sprite.new(0, 0, :interface_cursor)

    start
  end

  def start
    @paused = false
    @buttons[0].enabled = true
    @buttons[0].update_text(:pause)
    @txt_name.text = ''
    @confirmation = @game_over = @high_scores_rank = nil

    @objects = Array.new(NUM_COLS) do
      Array.new(NUM_ROWS)
    end
    @level = 1
    @score = 0
    @matches = []
    @match_count = 0
    @high_scores_highlight = 0
    @effects = []
  end

  def add_sphere(col, row, type, locked = false, ceiling = false)
    y = @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE
    y -= SPHERE_SIZE if ceiling
    @objects[col][row] = Sphere.new(type, locked, @margin.x + col * SPHERE_SIZE, y)
  end

  def add_lock(col, row, ceiling = true)
    y = @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE
    y -= SPHERE_SIZE if ceiling
    @objects[col][row] = Lock.new(@margin.x + col * SPHERE_SIZE, y)
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
        if same_line
          if obj.type == match.type
            match.chain = obj.chain if obj.chain > match.chain
            match.count += 1
          elsif obj.type == :rainbow
            match.type = "#{match.type}_rainbow".to_sym unless match.type.to_s.end_with?('rainbow')
            match.chain = obj.chain if obj.chain > match.chain
            match.count += 1
          elsif match.type.to_s.end_with?('rainbow')
            if obj.type == match.type.to_s.split('_')[0].to_sym
              match.chain = obj.chain if obj.chain > match.chain
              match.count += 1
            else
              p_col = horizontal ? col - 1 : col
              p_row = horizontal ? row : row - 1
              if @objects[p_col][p_row].type == :rainbow
                chain = [@objects[p_col][p_row].chain, obj.chain].max
                matches << Match.new("#{obj.type}_rainbow".to_sym, horizontal, p_col, p_row, chain)
                matches[-1].count = 2
              else
                matches << Match.new(obj.type, horizontal, col, row, obj.chain)
              end
            end
          else
            matches << Match.new(obj.type, horizontal, col, row, obj.chain)
          end
        else
          matches << Match.new(obj.type, horizontal, col, row, obj.chain)
        end
      end
    end
    matches
  end

  def check_game_over
    return unless (0...NUM_COLS).any? { |i| @objects[i][NUM_ROWS - 1]&.stopped }

    high_scores_table = Game.scores[@high_scores_table_index]
    if (index = high_scores_table.find_index { |e| e[1].to_i <= @score })
      @high_scores_rank = index
      @game_over = :enter_name
      @txt_name.focus
    elsif high_scores_table.size < MAX_HIGH_SCORES_ENTRIES
      @high_scores_rank = high_scores_table.size
      @game_over = :enter_name
      @txt_name.focus
    else
      @game_over = :high_scores
    end
    @buttons[0].enabled = false
  end

  def check_level_up
    return unless @match_count >= @matches_to_level_up

    @match_count -= @matches_to_level_up
    @level += 1
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE + (@level - 1) * MATCHES_TO_LEVEL_UP_INCR
    @spawn_interval = [SPAWN_INTERVAL_BASE - (@level - 1) * SPAWN_INTERVAL_DECR, SPAWN_INTERVAL_MIN].max
    @effects << TextEffect.new(SCREEN_WIDTH / 2, 250, Locl.text(:level_up), 120)
  end

  def update
    if @confirmation
      @confirm_buttons.each(&:update)
      return
    elsif @game_over
      if @game_over == :enter_name
        @txt_name.update
        @high_score_button.update
      else
        @buttons.each(&:update)
        if @high_scores_rank
          @high_scores_highlight += 1
          if @high_scores_highlight >= 120
            @high_scores_highlight = 0
          end
        end
      end
      return
    end

    @buttons.each(&:update)
    return if @paused

    @effects.reverse_each do |e|
      e.update
      @effects.delete(e) if e.dead?
    end

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
        @effects << TextEffect.new(
          @margin.x + (m.col + ((m.horizontal ? m.count : 1) * 0.5)) * SPHERE_SIZE,
          @margin.y + (NUM_ROWS - m.row - (m.horizontal ? 1 : (m.count + 1) * 0.5)) * SPHERE_SIZE + 2,
          m.score.to_s
        )
        @score += m.score
      end
      @match_count += @matches.count

      (0...NUM_ROWS).each do |j|
        (0...NUM_COLS).each do |i|
          obj = @objects[i][j]
          if obj.is_a?(Sphere) && obj.stopped
            obj.unchain!
          elsif obj.is_a?(Lock)
            obj.update
            @objects[i][j] = nil if obj.dead?
          end
        end
      end
    end

    return unless game_cursor?

    # player action
    col = (Mouse.x - @margin.x) / SPHERE_SIZE
    col = NUM_COLS - 2 if col >= NUM_COLS - 1
    mouse_row = (Mouse.y - @margin.y) / SPHERE_SIZE
    row = NUM_ROWS - mouse_row - 1
    row_y = @margin.y + mouse_row * SPHERE_SIZE
    @cursor.x = @margin.x + col * SPHERE_SIZE
    @cursor.y = row_y

    if block_given?
      yield row
    elsif Mouse.button_pressed?(:left)
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
  end

  def game_cursor?
    @confirmation.nil? && @game_over.nil? && !@paused &&
      Mouse.x >= @margin.x && Mouse.x < @margin.x + NUM_COLS * SPHERE_SIZE &&
      Mouse.y >= @margin.y && Mouse.y < @margin.y + NUM_ROWS * SPHERE_SIZE
  end

  def draw
    @bg.draw(235, 90, 0)

    @objects.flatten.each { |s| s&.draw }
    @effects.each(&:draw)
    @cursor.draw if game_cursor?

    @fg.draw(0, 0, 0)

    text_helper = Game.text_helper
    text_helper.write_line(Locl.text(:level, @level), 10, 105, :left, TEXT_COLOR)
    text_helper.write_line(Locl.text(:score, @score), 10, 175, :left, TEXT_COLOR)
    @buttons.each(&:draw)

    if @confirmation
      G.window.draw_quad(0, 0, 0x80000000,
                         SCREEN_WIDTH, 0, 0x80000000,
                         0, SCREEN_HEIGHT, 0x80000000,
                         SCREEN_WIDTH, SCREEN_HEIGHT, 0x80000000, 100)
      @dialog.draw((SCREEN_WIDTH - @dialog.width) / 2, (SCREEN_HEIGHT - @dialog.height) / 2, 100)
      text_helper.write_line(Locl.text(:are_you_sure, Locl.text(@confirmation).downcase),
                             SCREEN_WIDTH / 2,
                             (SCREEN_HEIGHT - @dialog.height) / 2 + 65,
                             :center, TEXT_COLOR, 255, nil, 0, 0, 0, 100)
      @confirm_buttons.each { |b| b.draw(100) }
    elsif @game_over
      G.window.draw_quad(0, 0, 0x80000000,
                         SCREEN_WIDTH, 0, 0x80000000,
                         0, SCREEN_HEIGHT, 0x80000000,
                         SCREEN_WIDTH, SCREEN_HEIGHT, 0x80000000, 100) if @game_over == :enter_name
      text_helper.write_line(Locl.text(:game_over), SCREEN_WIDTH / 2, 120, :center, 0xffffff, 255, :border, 0x006666, 2, 127, 100, 1.5, 1.5)
      if @game_over == :enter_name
        @dialog.draw((SCREEN_WIDTH - @dialog.width) / 2, (SCREEN_HEIGHT - @dialog.height) / 2, 100)
        text_helper.write_line(Locl.text(:enter_name),
                               SCREEN_WIDTH / 2,
                               (SCREEN_HEIGHT - @dialog.height) / 2 + 30,
                               :center, TEXT_COLOR, 255, nil, 0, 0, 0, 100)
        @txt_name.draw(255, 100)
        @high_score_button.draw(100)
      else
        Game.scores[@high_scores_table_index].each_with_index do |entry, i|
          color = if i == @high_scores_rank
                    r = @high_scores_highlight < 60 ?
                          255 - ((@high_scores_highlight / 60.0) * 255).round :
                          (((@high_scores_highlight - 60) / 60.0) * 255).round
                    g_b = @high_scores_highlight < 60 ?
                          255 - ((@high_scores_highlight / 60.0) * 153).round :
                          104 + (((@high_scores_highlight - 60) / 60.0) * 153).round
                    (r << 16) | (g_b << 8) | g_b
                  else
                    0xffffff
                  end
          text_helper.write_line("#{i + 1}. #{entry[0]}", 250, 200 + i * 28, :left, color, 255, :border, 0x006666, 1, 127, 100)
          text_helper.write_line(entry[1], SCREEN_WIDTH - 250, 200 + i * 28, :right, color, 255, :border, 0x006666, 1, 127, 100)
        end
      end
    end
  end
end
