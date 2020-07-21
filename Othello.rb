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

  def game_situation
    black,white = count_black_and_white
    puts "黒:#{black},白:#{white}".center(17)
    pass_case_action
    game_continuing?
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

    def game_continuing?
      black,white = count_black_and_white
      if game_set?
        puts "黒:#{black},白:#{white}".center(17)
        puts "引き分け".center(17) if black == white
        return false              if black == white
        puts black < white ? "白の勝ち".center(17) : "黒の勝ち".center(17)
        return false
      end
      true
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
    end

    def within_range(i,j)
      i<8 && j<8 && i>=0 && j>=0
    end
end

class Piece
  attr_accessor :color
end

class Othello
  attr_accessor :board
  def initialize
    puts "オセロゲーム".center(17)
    @board = Board.new
    mode_select
  end

  private

  def mode_select
    puts "どれにしますか？番号を入力して下さい"
    puts "1.人対コンピュータ, 2.人対人, 3.コンピュータ対コンピュータ"
    i = gets.to_i
    case i
    when 1
      select_your_color
    when 2
      board.puts_field
      man_vs_man
    when 3
      board.puts_field
      computer_vs_computer
    else
      puts "もう一度入力して下さい。"
      return mode_select
    end
  end

  def select_your_color
    puts "どちらにしますか？番号を入力して下さい"
    puts "1 黒番, 2 白番"
    i = gets.to_i
    board.puts_field
    case i
    when 1
      man_vs_computer
    when 2
      computer_vs_man
    else
      puts "もう一度入力して下さい"
      select_your_color
    end
  end

  def ask_continue?
    puts "もう一度プレイしますか？"
    puts "1 はい, 2 いいえ (番号を入力して下さい)"
    i = gets.to_i
    case i
    when 1
      board.game_init
      mode_select
    when 2
      puts "終了します"
      exit
    else
      puts "もう一度入力して下さい"
      ask_continue?
    end
  end

  def man_vs_man
    unless man_turn
      board.puts_field
      return ask_continue?
    end
    man_vs_man
  end

  def man_vs_computer
    man_turn
    unless computer_turn
      board.puts_field
      return ask_continue?
    end
    man_vs_computer
  end

  def computer_vs_man
    unless computer_turn
      board.puts_field
      return ask_continue?
    end
    unless man_turn
      board.puts_field
      return ask_continue?
    end
    man_vs_computer
  end

  def computer_vs_computer
    unless computer_turn
      board.puts_field
      return ask_continue?
    end
    computer_vs_computer
  end

  def man_turn
    put_request
    board.next_turn
    return false unless board.game_situation
    board.puts_field
  end

  def computer_turn
    board.auto_put_piece
    board.next_turn
    return false unless board.game_situation
    board.puts_field
  end

  def put_request
    print "縦 横: "
    i,j = gets.split.map(&:to_i)
    if i.nil? || j.nil?
      puts "もう一度入力して下さい"
      return put_request
    end
    put_request unless board.put_piece(i,j)
  end
end

class Array
  def remove_from_empty_cells(i,j)
    self.delete([i,j])
  end
end

# board = Board.new
# board.puts_field
# i,j = gets.split.map(&:to_i)
# board.put_piece(i,j)
# board.puts_field
# Othello.new.computer_vs_computer
Othello.new
