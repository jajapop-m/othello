class Board
  attr_accessor :piece, :field, :my_color, :enemy_color, :empty_cells
  def initialize
    game_init
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
    i -= 1
    j -= 1
    return puts "そこは置けません" unless putable?(i,j)
    turn_pieces(i,j)
    field[i][j] = my_color
    empty_cells.remove_from_empty_cells(i,j)
  end

  def auto_put_piece
    sample = max_cells.sample
    i,j = sample[1]+1,sample[2]+1
    put_piece(i,j)
  end

  def current_judge
    black,white = count_black_and_white
    puts "黒:#{black},白:#{white}".center(17)
    pass_case_action
    game_over?
  end

  def puts_field
    cur_stat = Array.new(8){Array.new(8)}
    field.each_with_index do |f,i|
      f.each_with_index do |cell,j|
        next cur_stat[i][j] = "□".to_s.rjust(2) if cell == :none
        next cur_stat[i][j] = "●".to_s.rjust(2) if cell == :black
        next cur_stat[i][j] = "◎".to_s.rjust(2) if cell == :white
      end
    end
    puts_field_with_line_numbers(cur_stat)
  end

  private

    def turn_pieces(i,j)
      gathering_turnable_pieces(i,j).each do |line|
        line.each_slice(2) {|i,j| field[i][j] = my_color }
      end
    end

    def putable?(i,j)
      !!putable_cells.find_index([i,j])
    end

    def putable_cells
      putable_cells = []
      empty_cells.each do |i,j|
        turnable_num = numbers_of_turnable_pieces(i,j)
        putable_cells << [i,j] if turnable_num > 0
      end
      putable_cells
    end

    def max_cells
      max = [0]
      empty_cells.each do |i,j|
        turnable_num = numbers_of_turnable_pieces(i,j)
        if max[0] <= turnable_num
          max[0] = turnable_num
          max << [turnable_num,i,j]
        end
      end
      m = max.shift
      max.delete_if{|cell| cell[0]!=m}
      max
    end

    def numbers_of_turnable_pieces(i,j)
      num = 0
      gathering_turnable_pieces(i,j).each do |piece|
        num += 1 unless piece.empty?
      end
      num
    end

    def gathering_turnable_pieces(i,j)
      @change_color_stocks = []
      [[1,0],[-1,0],[0,1],[0,-1],[1,1],[-1,1],[1,-1],[-1,-1]].each do |a,b|
        check_line(i,j,a,b,ary=[]) if within_range(i+a,j+b) && field[i+a][j+b] == enemy_color
      end
      @change_color_stocks
    end

    def check_line(i,j,a,b,ary)
      return ary.clear if !within_range(i+a,j+b) || field[i+a][j+b] == :none
      if field[i+a][j+b] == my_color
        @change_color_stocks << ary.flatten
      end
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
        return true               if black == white
        puts black < white ? "白の勝ち".center(17) : "黒の勝ち".center(17)
        return true
      end
      false
    end

    def game_set?
      if putable_cells.empty?
        next_turn
        if putable_cells.empty?
          return true
        end
        next_turn
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
