class Board
  attr_accessor :piece, :field, :my_color, :enemy_color, :empty_cells
  def initialize
    @field = Array.new(8){Array.new(8,:none)}
    field[3][3] = :black
    field[3][4] = :white
    field[4][3] = :white
    field[4][4] = :black
    @my_color = :black
    @enemy_color = :white
    @empty_cells = []
    for i in 0..8
      for j in 0..8
        empty_cells << [i,j]
      end
    end
    empty_cells.remove_from_empty_cells(3,3)
    empty_cells.remove_from_empty_cells(3,4)
    empty_cells.remove_from_empty_cells(4,3)
    empty_cells.remove_from_empty_cells(4,4)
  end

  def next_turn
    @my_color, @enemy_color = enemy_color, my_color
  end

  Array.class_eval do
    def remove_from_empty_cells(i,j)
      self.delete([i,j])
    end
  end

  def put_piece(i,j)
    i -= 1
    j -= 1
    if putable?(i,j)
      field[i][j] = my_color
      turn_pieces(i,j)
      empty_cells.remove_from_empty_cells(i,j)
    else
      puts "そこには置けません"
    end
  end

  def turn_pieces(i,j)
    stocks = gathering_turnable_pieces(i,j)
    stocks.each do |a|
      a.each_slice(2) do |i,j|
        field[i][j] = my_color
      end
    end
  end

  def gathering_turnable_pieces(i,j)
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

  def within_range(i,j)
    i<8 && j<8 && i>=0 && j>=0
  end

  def putable?(i,j)
    !!check_putable_cells.find_index([i,j])
  end

  def check_putable_cells
    putable_cells = []
    empty_cells.each do |i,j|
      count = 0
      gathering_turnable_pieces(i,j).each do |piece|
        count += 1 unless piece.empty?
      end
      putable_cells << [i,j] if count > 0
    end
    putable_cells
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
