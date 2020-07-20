class Board
  attr_accessor :piece, :field, :change_color
  def initialize
    @field = Array.new(8){Array.new(8,:none)}
    field[3][3] = :black
    field[3][4] = :white
    field[4][3] = :white
    field[4][4] = :black
  end

  def put_piece(i,j)
    i -= 1
    j -= 1
    field[i][j] = :black
    turn_pieces(i,j)
  end

  def turn_pieces(i,j)
    @change_color = []
    ary = []
    b_count = check_bottom(i,j,ary)
    top =    check_top(i,j,ary)
    right =  check_right(i,j,ary)
    left =   check_left(i,j,ary)
    change_color.each do |i,j|
      field[i][j] = :black
    end
  end

  def check_bottom(i,j,a)
    return a.clear unless validate(i+1,j)
    if field[i+1][j] == :black
      change_color << a.flatten(1)
      return change_color.length
    end
    a << [i+1,j]
    check_bottom(i+1,j,a)
  end

  def check_top(i,j,a)
    return a.clear unless validate(i-1,j)
    if field[i-1][j] == :black
      change_color << a.flatten(1)
      return [change_color.length]
    end
    a << [i-1,j]
    check_top(i-1,j,a)
  end

  def check_right(i,j,a)
    return a.clear unless validate(i,j+1)
    if field[i][j+1] == :black
      change_color << a.flatten(1)
      return [change_color.length]
    end
    a << [i,j+1]
    check_right(i,j+1,a)
  end

  def check_left(i,j,a)
    return a.clear unless validate(i,j-1)
    if field[i][j-1] == :black
      change_color << a.flatten(1)
      return [change_color.length]
    end
    a << [i,j-1]
    check_left(i,j-1,a)
  end

  def validate(i,j)
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

end

board = Board.new
board.puts_field
i,j = gets.split.map(&:to_i)
board.put_piece(i,j)
board.puts_field
