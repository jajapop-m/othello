class Board
  attr_accessor :all_pieces, :all_cells, :empty_cells, :my_color, :enemy_color, :black_win, :white_win, :even, :othello
  Min, Max = 64, 0
  Corner = [[0,0],[0,7],[7,0],[7,7]]
  Side = [[0,2],[0,3],[0,4],[0,5],[2,0],[2,7],[3,0],[3,7],[4,0],[4,7],[5,0],[5,7],[7,2],[7,3],[7,4],[7,5]]
  Sub_Corner = [[0,1],[0,6],[1,0],[1,1],[1,6],[1,7],[6,0],[6,1],[6,6],[6,7],[7,1],[7,6]]
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
    (center_b + center_w).each {|i,j| empty_cells.remove_from_empty_cells(i,j)}
    piece(3,3).openness = 5
    piece(3,4).openness = 5
    piece(4,3).openness = 5
    piece(4,4).openness = 5
  end

  def next_turn
    @my_color, @enemy_color = enemy_color, my_color
  end

  def auto_put_request
    sample = turnable(Corner)&.sample
    sample ||= turnable(Side)&.sample
    sample ||= max_or_min_cells(Max, @max_cells_condition).sample if empty_cells.length <= 20
    sample ||= (max_or_min_cells(Min, @min_cells_condition) & get_min_openness_cells).sample if empty_cells.length >= 40
    sample ||= max_or_min_cells(Min, @min_cells_condition).sample if empty_cells.length >= 21
    [sample[1]+1,sample[2]+1]
  end

  def auto_put_request_v2
    sample ||= max_or_min_cells(Max, @max_cells_condition).sample
    [sample[1]+1,sample[2]+1]
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
    empty_cells.remove_from_empty_cells(i,j)
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

    def piece(i,j)
      all_pieces[i][j] if within_range?(i,j)
    end

    def max_or_min_cells(i,proc)
      @cells = [i]
      empties = empty_cells - Sub_Corner
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

    def sum_openness(i,j)
      sum = 0
      turnable_pieces(i,j).each do |a,b|
        sum += piece(a,b).openness
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
      openness_list
    end

    def max_or_min_cells_v2(i,proc)
      @cells = [i]
      # empties = empty_cells - Sub_Corner
      empties = empty_cells # if (putable_cells & empties).empty?
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

    def turnable(c_or_s)
      corners_or_sides =[]
      c_or_s.each do |i,j|
        corners_or_sides << [:corner_side,i,j] if able_to_put?(i,j)
      end
      return nil if corners_or_sides.empty?
      corners_or_sides
    end

    def check_line_if_turnable(i,j,a,b,ary)
      return ary.clear if !within_range?(i+a,j+b) || piece(i+a,j+b).color?(:none)
      return @change_color_stocks << ary.flatten if piece(i+a,j+b).color?(my_color)
      ary << [i+a,j+b]
      check_line_if_turnable(i+a,j+b,a,b,ary)
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
  def remove_from_empty_cells(i,j)
    self.delete([i,j])
  end
end
