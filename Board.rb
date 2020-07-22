class Board
  attr_accessor :piece, :field, :my_color, :enemy_color, :empty_cells, :black_win, :white_win, :even
  Max, Min = 64, 0
  Corner = [[0,0],[0,7],[7,0],[7,7]]
  Side = [[0,2],[0,3],[0,4],[0,5],[2,0],[2,7],[3,0],[3,7],[4,0],[4,7],[5,0],[5,7],[7,2],[7,3],[7,4],[7,5]]
  Sub_Corner = [[0,1],[0,6],[1,0],[1,1],[1,6],[1,7],[6,0],[6,1],[6,6],[6,7],[7,1],[7,6]]
  def initialize
    game_init
    @black_win, @white_win, @even = 0,0,0
    @max_cells_condition = -> {@cells[0] <= @turnable_num}
    @min_cells_condition = -> {@turnable_num != 0 && @cells[0] >= @turnable_num}
  end

  def game_init
    center_b = [[3,3],[4,4]]
    center_w = [[3,4],[4,3]]
    @field = Array.new(8){Array.new(8,:none)}
    center_b.each{|i,j| field[i][j] = :black}
    center_w.each{|i,j| field[i][j] = :white}
    @my_color, @enemy_color = :black, :white
    @empty_cells = []
    (0..7).each do |i|
      (0..7).each do |j|
        empty_cells << [i,j]
      end
    end
    (center_b + center_w).each {|i,j| empty_cells.remove_from_empty_cells(i,j)}
  end

  def next_turn
    @my_color, @enemy_color = enemy_color, my_color
  end

  def put_piece(i,j)
    i -= 1; j -= 1
    return puts "そこは置けません" unless able_to_put?(i,j)
    turn_pieces(i,j)
    field[i][j] = my_color
    empty_cells.remove_from_empty_cells(i,j)
  end

  def auto_put_piece
    sample = turnable(Corner)&.sample
    sample ||= turnable(Side)&.sample
    sample ||= max_or_min_cells(Min,@max_cells_condition).sample if empty_cells.length <= 25
    sample ||= max_or_min_cells(Max,@min_cells_condition).sample if empty_cells.length >= 26
    i,j = sample[1]+1,sample[2]+1
    put_piece(i,j)
  end

  # auto_run
  # def auto_put_piece_v2
  #   sample = max_or_min_cells_v2(Min,@max_cells_condition).sample
  #   i,j = sample[1]+1,sample[2]+1
  #   put_piece(i,j)
  # end

  def current_judge
    black,white = count_black_and_white
    puts "黒:#{black},白:#{white}".center(17)
    pass_case_action
    game_over?
  end

  def puts_field
    cur_stat = Array.new(8){Array.new(8)}
    field.each_with_index do |line,i|
      line.each_with_index do |cell,j|
        next cur_stat[i][j] = "□".to_s.rjust(2) if cell == :none
        next cur_stat[i][j] = "●".to_s.rjust(2) if cell == :black
        next cur_stat[i][j] = "◎".to_s.rjust(2) if cell == :white
      end
    end
    puts_field_with_line_numbers(cur_stat)
  end

  def game_set?
    if putable_cells.empty?
      next_turn
      return true if putable_cells.empty?
      next_turn
    end
    false
  end

  def stock_win_count

  end

  private

    def turn_pieces(i,j)
      turnable_pieces(i,j).each do |line|
        line.each_slice(2) {|i,j| field[i][j] = my_color }
      end
    end

    def able_to_put?(i,j)
      putable_cells.include?([i,j])
    end

    def putable_cells
      putable_cells = []
      empty_cells.each do |i,j|
        turnable_num = numbers_of_turnable_pieces(i,j)
        putable_cells << [i,j] if turnable_num > 0
      end
      putable_cells
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
      [[1,0],[-1,0],[0,1],[0,-1],[1,1],[-1,1],[1,-1],[-1,-1]].each do |a,b|
        check_line(i,j,a,b,ary=[]) if within_range(i+a,j+b) && field[i+a][j+b] == enemy_color
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

    def check_line(i,j,a,b,ary)
      return ary.clear if !within_range(i+a,j+b) || field[i+a][j+b] == :none
      return @change_color_stocks << ary.flatten if field[i+a][j+b] == my_color
      ary << [i+a,j+b]
      check_line(i+a,j+b,a,b,ary)
    end

    def print_color(color)
      return "黒" if color == :black
      return "白" if color == :white
    end

    def game_over?
      black,white = count_black_and_white
      if game_set?
        puts "黒:#{black},白:#{white}".center(17)
        puts "引き分け".center(17) if black == white
        return @even += 1          if black == white
        puts black < white ? "白の勝ち".center(17) : "黒の勝ち".center(17)
        return black < white ? (@white_win += 1) : (@black_win += 1)
      end
      false
    end

    def pass_case_action
      if pass?
        next_turn
        puts_field
        puts "#{print_color(my_color)}:パスです。"
        next_turn
      end
    end

    def pass?
      if putable_cells.empty?
        next_turn
        return true
      end
    end

    def count_black_and_white
      black,white = 0,0
      field.each do |line|
        line.each do |cell|
          black += 1 if cell == :black
          white += 1 if cell == :white
        end
      end
      [black,white]
    end

    def puts_field_with_line_numbers(cur_stat)
      puts "#{print_color(my_color)}番" unless game_set?
      cur_stat_with_line_numbers = Array.new(8){Array.new(8)}
      cur_stat.each_with_index do |line,i|
        cur_stat_with_line_numbers[i] = line.unshift(i+1)
      end
      cur_stat_with_line_numbers.unshift([*1..8])[0].unshift(" ")
      cur_stat_with_line_numbers.each do |line|
        line.each do |l|
          print l.to_s.rjust(2)
        end
        puts "\r"
      end
      nil
    end

    def within_range(i,j)
      i<8 && j<8 && i>=0 && j>=0
    end
end

class Piece
  attr_accessor :color
end

class Array
  def remove_from_empty_cells(i,j)
    self.delete([i,j])
  end
end
