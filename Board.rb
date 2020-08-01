class Board
  attr_accessor :all_pieces, :all_cells, :empty_cells, :my_color, :enemy_color, :black_win, :white_win, :even, :othello
  Min, Max = 64, 0
  Corner = [[0,0],[0,7],[7,0],[7,7]]
  Sub_Corner = [[0,1],[0,6],[1,0],[1,1],[1,6],[1,7],[6,0],[6,1],[6,6],[6,7],[7,1],[7,6]]
  Second_Corner = [[1,1],[1,6],[6,1],[6,6]]
  Four_corners = [[[0,0],[0,1],[1,0],[1,1]], [[0,6],[0,7],[1,6],[1,7]], [[6,0],[6,1],[7,0],[7,1]], [[6,6],[6,7],[7,6],[7,7]]]
  Side = [[[0,2],[0,3],[0,4],[0,5]],[[2,0],[3,0],[4,0],[5,0]],[[2,7],[3,7],[4,7],[5,7]],[[7,2],[7,3],[7,4],[7,5]]]
  Inner_Side = [[1,2],[1,3],[1,4],[1,5],[2,1],[2,6],[3,1],[3,6],[4,1],[4,6],[5,1],[5,6],[6,2],[6,3],[6,4],[6,5]]
  Around_the_piece = [[1,0],[-1,0],[0,1],[0,-1],[1,1],[-1,1],[1,-1],[-1,-1]]

  def initialize
    game_init
    @black_win, @white_win, @even = 0,0,0
    @max_cells_condition = -> {@cells[0] <= @turnable_num}
    @min_cells_condition = -> {@turnable_num != 0 && @cells[0] >= @turnable_num}
  end

  def game_init
    center_b = [[3,3],[4,4]]
    center_w = [[3,4],[4,3]]
    @all_pieces = Array.new(8){Array.new(8){Piece.new}}
    center_b.each{|i,j| piece(i,j).color = :black}
    center_w.each{|i,j| piece(i,j).color = :white}
    @my_color, @enemy_color = :black, :white
    @empty_cells = [] ; @all_cells = []
    (0..7).each do |i|
      (0..7).each do |j|
        empty_cells << [i,j]
        all_cells << [i,j]
      end
    end
    (center_b + center_w).each {|i,j| empty_cells.remove_cells(i,j)}
    (center_b + center_w).each {|i,j| piece(i,j).openness = 5}
  end

  def next_turn
    @my_color, @enemy_color = enemy_color, my_color
  end

  def auto_put_request
    sample = if_two_remain_get_better_move&.sample
    sample ||= only_one_corner_cell&.sample if closing_stage
    sample ||= turnable(Corner)&.sample
    sample ||= get_wing&.sample
    sample ||= get_min_inner_sides(turnable(Side.flatten(1)))&.sample if middle_stage
    sample ||= turnable(Side)&.sample
    sample ||= (max_or_min_cells(Min, @min_cells_condition) & get_min_openness_cells).sample if early_stage || middle_stage
    sample ||= max_or_min_cells(Min, @min_cells_condition).sample if early_stage || middle_stage
    sample ||= max_or_min_cells(Max, @max_cells_condition).sample if closing_stage
    [sample[1]+1,sample[2]+1]
  end

  # より強い手を作成するための比較として使用
  def auto_put_request_v2
    sample = max_or_min_cells_v2(Max, @max_cells_condition).sample
    [sample[1]+1,sample[2]+1]

    # sample = if_two_remain_get_better_move&.sample
    # sample ||= only_one_corner_cell&.sample if closing_stage
    # sample ||= turnable(Corner)&.sample
    # sample ||= get_min_inner_sides(turnable(Side))&.sample if middle_stage
    # sample ||= turnable(Side)&.sample
    # sample ||= (max_or_min_cells(Min, @min_cells_condition) & get_min_openness_cells).sample if early_stage || middle_stage
    # sample ||= max_or_min_cells(Min, @min_cells_condition).sample if early_stage || middle_stage
    # sample ||= max_or_min_cells(Max, @max_cells_condition).sample if closing_stage
    # [sample[1]+1,sample[2]+1]
  end

  def putable_cells
    putable_cells = []
    empty_cells.each do |i,j|
      turnable_num = numbers_of_turnable_pieces(i,j)
      putable_cells << [i,j] if turnable_num > 0
    end
    putable_cells
  end

  def put_and_turn_pieces(i,j)
    piece(i,j).color = my_color
    turnable_pieces(i,j).each do |line|
      line.each_slice(2) {|i,j| piece(i,j).color = my_color }
    end
    empty_cells.remove_cells(i,j)
  end

  def able_to_put?(i,j)
    putable_cells.include?([i,j])
  end

  def count_black_and_white
    black,white = 0,0
    all_pieces.each do |line|
      line.each do |piece|
        black += 1 if piece.color? :black
        white += 1 if piece.color? :white
      end
    end
    [black,white]
  end

  def game_over?
    if putable_cells.empty?
      next_turn
      return true if putable_cells.empty?
      next_turn
    end
    false
  end

  def game_over_results
    if game_over?
      black, white = count_black_and_white
      if black == white
        @even += 1
        return [:even, black, white]
      elsif black < white
        @white_win += 1
        return [:white, black, white]
      else
        @black_win += 1
        return [:black, black, white]
      end
    end
    nil
  end

  def calcurate_openness(i,j)
    count = 0
    Around_the_piece.each do |a,b|
      next unless within_range?(i+a,j+b)
      if piece(i+a,j+b)&.color?(:black) || piece(i+a,j+b)&.color?(:white)
        piece(i+a,j+b).openness -= 1
        count += 1
      end
    end
    piece(i,j).openness -= count
  end

  private

    def early_stage
      empty_cells.length >= 42
    end

    def middle_stage
      empty_cells.length <= 41 && empty_cells.length >= 21
    end

    def closing_stage
      empty_cells.length <= 20
    end

    def piece(i,j)
      all_pieces[i][j] if within_range?(i,j)
    end

    def max_or_min_cells(i,proc)
      @cells = [i]
      empties = empty_cells - Sub_Corner
      empties = empty_cells - Second_Corner if (putable_cells & empties).empty?
      empties = empty_cells - Second_Corner if (putable_cells & empties).empty?
      empties = empty_cells if (putable_cells & empties).empty?
      empties.each do |i,j|
        @turnable_num = numbers_of_turnable_pieces(i,j)
        if proc.call
          @cells[0] = @turnable_num
          @cells << [@turnable_num,i,j]
        end
      end
      m = @cells.shift
      @cells.delete_if{|cell| cell[0]!=m}
    end

  # より強い手を作成するための比較として使用
    def max_or_min_cells_v2(i,proc)
      @cells = [i]
      # empties = empty_cells - Sub_Corner
      # empties = empty_cells - Second_Corner if (putable_cells & empties).empty?
      empties = empty_cells #if (putable_cells & empties).empty?
      empties.each do |i,j|
        @turnable_num = numbers_of_turnable_pieces(i,j)
        if proc.call
          @cells[0] = @turnable_num
          @cells << [@turnable_num,i,j]
        end
      end
      m = @cells.shift
      @cells.delete_if{|cell| cell[0]!=m}
    end

    def only_one_corner_cell
      only_one_corner = []
      Four_corners.each do |corner|
        only_one_corner << (corner & empty_cells).map{|a| a.unshift(:only_one)}
      end
      only_one_corner.delete_if{|p| p.length != 1}
      only_one_corner.each {|piece| piece.delete_if {|p| !able_to_put?(p[1],p[2])}}
      only_one_corner.compact.flatten(1)
    end

    def sum_openness(i,j)
      sum = 0
      turnable_pieces(i,j).each do |line|
        line.each_slice(2) { |a,b| sum += piece(a,b).openness}
      end
      sum
    end

    def get_min_openness_cells
      openness_list = []
      min_openness = 100
      putable_cells.each do |i,j|
        res = sum_openness(i,j)
        min_openness = res if min_openness > res
        openness_list << [res,i,j]
      end
      openness_list.delete_if{|list| list[0] != min_openness}
    end

    def numbers_of_turnable_pieces(i,j)
      num = 0
      turnable_pieces(i,j).each {|pieces| num = pieces.length / 2 }
      num
    end

    def turnable_pieces(i,j)
      @change_color_stocks = []
      Around_the_piece.each do |a,b|
        check_line_if_turnable(i,j,a,b,ary=[]) if within_range?(i+a,j+b) && piece(i+a,j+b).color?(enemy_color)
      end
      @change_color_stocks
    end

    def check_line_if_turnable(i,j,a,b,ary)
      return ary.clear if !within_range?(i+a,j+b) || piece(i+a,j+b).color?(:none)
      return @change_color_stocks << ary.flatten if piece(i+a,j+b).color?(my_color)
      ary << [i+a,j+b]
      check_line_if_turnable(i+a,j+b,a,b,ary)
    end

    def turnable(c_or_s)
      corners_or_sides =[]
      c_or_s.each do |i,j|
        corners_or_sides << [:corner_side,i,j] if able_to_put?(i,j)
      end
      return nil if corners_or_sides.empty?
      corners_or_sides
    end

    def get_min_inner_sides(sides)
      return nil if sides.nil?
      min = 16
      stock = []
      sides.each do |_,i,j|
        count = 0
        turnable_pieces(i,j).each do |line|
          line.each_slice(2) do |a,b|
            next count += 1 if Inner_Side.include?([a,b])
          end
          min = [min, count].min
          stock << [count,i,j]
        end
      end
      stock.delete_if{|piece| piece[0] != min}
    end

    def if_two_remain_get_better_move
      if empty_cells.length == 2 && putable_cells.length == 2
        both_can_put = []
        next_turn
        putable_cells.each{|i,j| both_can_put << [:better,i,j] }
        next_turn
        return both_can_put if both_can_put.length == 1
      end
    end

    def get_wing
      return if (Corner & empty_cells).length == 4
      wing = []
      (Sub_Corner - Second_Corner).each {|i,j| wing << [:wing, i,j] if wing?(i,j)}
      wing.delete_if{|p| !able_to_put?(p[1],[2])}
      return if wing.empty?
      wing
    end

    def wing?(i,j)
      return false unless piece(i,j).color?(:none) || within_range?(i,j)
      [[0,-1,0,6,:+],[-1,0,6,0,:+],[0,1,0,-6,:-],[1,0,-6,0,:-]].each do |k,l,m,n,cal|
        if Corner.include?([i+k,j+l]) && piece(i+k,j+l).color?(enemy_color) && piece(i+m,j+n).color?(:none)
          (1..5).each {|a| return false unless piece(i.send(cal,a),j).color?(enemy_color)} if k != 0
          (1..5).each {|b| return false unless piece(i,j.send(cal,b)).color?(enemy_color)} if k == 0
          return true
        end
      end
      false
    end

    def within_range?(i,j)
      i<8 && j<8 && i>=0 && j>=0
    end
end

class Piece
  attr_accessor :color, :openness
  def initialize
    @color = :none
    @openness = 8
  end

  def color?(c)
    color == c
  end
end

class Array
  def remove_cells(i,j)
    self.delete([i,j])
  end
end
