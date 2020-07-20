class Board
  attr_accessor :piece, :field, :change_color_stocks, :my_color, :enemy_color
  def initialize
    @field = Array.new(8){Array.new(8,:none)}
    field[3][3] = :black
    field[3][4] = :white
    field[4][3] = :white
    field[4][4] = :black
    @my_color = :black
    @enemy_color = :white
  end

  def next_turn
    @my_color, @enemy_color = enemy_color, my_color
  end

  def put_piece(i,j)
    i -= 1
    j -= 1
    field[i][j] = my_color
    turn_pieces(i,j)
  end

  def turn_pieces(i,j)
    @change_color_stocks = []
    ary = []
    check_line(i,j,1,0,ary)
    check_line(i,j,-1,0,ary)
    check_line(i,j,0,1,ary)
    check_line(i,j,0,-1,ary)
    check_line(i,j,1,1,ary)
    check_line(i,j,1,-1,ary)
    check_line(i,j,-1,1,ary)
    check_line(i,j,-1,-1,ary)
    change_color_stocks.each do |a|
      a.each_slice(2) do |i,j|
        field[i][j] = my_color
      end
    end
  end

  def check_line(i,j,a,b,ary)
    # ary << [i,j]
    return ary.clear if !within_range(i+a,j+b) || field[i+a][j+b] == :none
    if field[i+a][j+b] == my_color
      @change_color_stocks << ary.flatten
      return change_color_stocks.length
    end
    ary << [i+a,j+b]
    check_line(i+a,j+b,a,b,ary)
  end

  def within_range(i,j)
    i<8 && j<8 && i>=0 && j>=0
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
    add_line_numbers(cur_stat)
  end

  def add_line_numbers(cur_stat)
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
  end

end

class Piece
  attr_accessor :color
end

class Othello
  attr_accessor :board
  def initialize
    @board = Board.new
    board.puts_field
  end

  def one_turn
    i,j = gets.split.map(&:to_i)
    board.put_piece(i,j)
    board.puts_field
    board.next_turn
    one_turn
  end
end

# board = Board.new
# board.puts_field
# i,j = gets.split.map(&:to_i)
# board.put_piece(i,j)
# board.puts_field
Othello.new.one_turn
