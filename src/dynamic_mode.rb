require_relative 'game_mode'
require_relative 'item'

class DynamicMode < GameMode
  def initialize(difficulty)
    @difficulty = difficulty
    super()
    @high_scores_table_index, @thresholds =
      case difficulty
      when :easy   then [1, [1, 2, 3]]
      when :normal then [2, [2, 4, 6]]
      when :hard   then [3, [3, 6, 9]]
      else              [4, [4, 8, 12]]
      end

    @item_slot = Res.img(:interface_itemShower)
  end

  def start
    super

    @level, starting_rows = case @difficulty
                            when :easy   then [1, 0]
                            when :normal then [3, 2]
                            when :hard   then [6, 4]
                            else              [10, 6]
                            end
    @matches_to_level_up = MATCHES_TO_LEVEL_UP_BASE + (@level - 1) * MATCHES_TO_LEVEL_UP_INCR
    @spawn_interval = [SPAWN_INTERVAL_BASE - (@level - 1) * SPAWN_INTERVAL_DECR, SPAWN_INTERVAL_MIN].max
    @spawn_timer = @spawn_interval - 30

    @item = nil
    @item_level = 1
    @item_score = 0
    @item_score_to_level_up = ITEM_SCORE_BASE

    (0...starting_rows).each do |j|
      (0...NUM_COLS).each do |i|
        type = BASIC_SPHERE_TYPES.sample
        while i >= 2 && @objects[i - 1][j].type == type && @objects[i - 2][j].type == type ||
          j >= 2 && @objects[i][j - 1].type == type && @objects[i][j - 2].type == type
          type = BASIC_SPHERE_TYPES.sample
        end

        add_sphere(i, j, type)
      end
    end
  end

  def check_item_level
    return if @item_score < @item_score_to_level_up

    item_type = ITEM_TYPES.sample
    @item = Item.new(item_type, @item_level, item_type == :line_converter ? BASIC_SPHERE_TYPES.sample : nil)
    @using_item = true

    @item_score -= @item_score_to_level_up
    @item_level += 1
    @item_score_to_level_up = ITEM_SCORE_BASE + (@item_level - 1) * ITEM_SCORE_INCREASE
  end

  def add_bomb_effect(col, row)
    @effects << MiniGL::Effect.new(@margin.x + col * SPHERE_SIZE,
                                   @margin.y + (NUM_ROWS - row - 1) * SPHERE_SIZE,
                                   :fx_blast, 3, 1, 8, [2, 1, 0, 1, 2])
  end

  def update
    prev_score = @score
    if @using_item
      super do |col, row|
        if @item.use(self, @objects, col, row)
          @item = nil
          @using_item = false
        end
      end
    else
      super
    end
    @item_score += @score - prev_score
    @using_item = false if Mouse.button_pressed?(:right)

    return if @confirmation || @game_over || @paused

    check_game_over
    return if @game_over

    check_level_up
    check_item_level

    @spawn_timer += 1
    return if @spawn_timer < @spawn_interval

    col = rand(NUM_COLS)
    row = NUM_ROWS - 1
    r = rand(100)
    if r < @thresholds[0]
      add_lock(col, row)
    elsif r < @thresholds[1]
      add_sphere(col, row, BASIC_SPHERE_TYPES.sample, true, true)
    elsif r < @thresholds[2]
      add_sphere(col, row, :rainbow, false, true)
    else
      add_sphere(col, row, BASIC_SPHERE_TYPES.sample, false, true)
    end

    @spawn_timer = 0
  end

  def draw
    super

    @item_slot.draw(80, 300, 0)

    if @item
      @item.icon.draw(90, 310, 0)
    end
  end
end
