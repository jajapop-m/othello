require './Board'

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
      # i = 3 # auto_run
      # exit if board.black_win + board.white_win + board.even > 200  # auto_run
      case i
      when 1
        select_your_color
      when 2
        puts_field
        man_vs_man
      when 3
        puts_field
        computer_vs_computer
        # computer_vs_computer2  # auto_run
      else
        puts "もう一度入力して下さい。"
        mode_select
      end
    end

    def select_your_color
      puts "どちらにしますか？番号を入力して下さい"
      puts "1 黒番, 2 白番"
      i = gets.to_i
      puts "ゲームを終了したい場合は、endまたはexitと入力して下さい。"
      puts_field
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

    def self.define_vs_method(computer_or_man1,computer_or_man2)
      define_method("#{computer_or_man1}_vs_#{computer_or_man2}") do
        send "#{computer_or_man1}_turn"
        return ask_continue? if board.game_over?
        send "#{computer_or_man2}_turn"
        return ask_continue? if board.game_over?
        send "#{computer_or_man1}_vs_#{computer_or_man2}"
      end
    end

    [[:man,:man],[:man,:computer],[:computer,:man],[:computer,:computer]].each do |cm1,cm2|
      define_vs_method(cm1,cm2)
    end

    define_vs_method(:computer,:computer2)

    def man_turn
      return if if_pass_next_turn
      put_request
      after_put_piece
    end

    def computer_turn
      return if if_pass_next_turn
      i,j = board.auto_put_request
      put_piece(i,j)
      after_put_piece
    end

    def computer2_turn
      return if if_pass_next_turn
      i,j = board.auto_put_request_v2
      put_piece(i,j)
      after_put_piece
    end

    def put_request
      print "縦 横: "
      i,j = gets.split
      return ask_retire? if i == "end" || i == "exit"
      return board.get_back_one_step if i == "back"
      if i.nil? || j.nil?
        puts "もう一度入力して下さい"
        return put_request
      end
      put_request unless put_piece(i.to_i,j.to_i)
    end

    def put_piece(i,j)
      i -= 1; j -= 1
      return puts "そこは置けません" unless board.able_to_put?(i,j)
      board.put_and_turn_pieces(i,j)
      board.calcurate_openness(i,j)
    end

    def after_put_piece
      board.next_turn
      puts_current_situation  # auto_run => off
      if_gameover_puts_result
      puts_field # auto_run => off
    end

    def puts_current_situation
      black,white = board.count_black_and_white
      puts "黒:#{black},白:#{white}".center(17)
    end

    def if_pass_next_turn
      return if board.game_over?
      if board.putable_cells.empty?
        puts "#{print_color(board.my_color)}:パスです。"
        board.next_turn
        puts_current_situation
        puts_field
        return true
      end
      false
    end

    def if_gameover_puts_result
      return unless board.game_over?
      result, black, white = board.game_over_results
      puts "黒:#{black},白:#{white}".center(17)
      puts "引き分け".center(17) if result == :even
      puts "黒の勝ち".center(17) if result == :black
      puts "白の勝ち".center(17) if result == :white
    end

    def puts_field
      cur_stat = Array.new(8){Array.new(8)}
      board.all_pieces.each_with_index do |line,i|
        line.each_with_index do |p,j|
          next cur_stat[i][j] = "□".to_s.rjust(2) if p.color?(:none)
          next cur_stat[i][j] = "●".to_s.rjust(2) if p.color?(:black)
          next cur_stat[i][j] = "◎".to_s.rjust(2) if p.color?(:white)
        end
      end
      puts_field_with_line_numbers(cur_stat)
    end

    def puts_field_with_line_numbers(cur_stat)
      puts "#{print_color(board.my_color)}番" unless board.game_over?
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

    def ask_continue?
      puts "黒#{board.black_win},白#{board.white_win},引き分け#{board.even}"
      puts "もう一度プレイしますか？"
      puts "1 はい, 2 いいえ (番号を入力して下さい)"
      i = gets.to_i
      # i = 1 # auto_run
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

    def ask_retire?
      puts "本当にゲームを終了しますか？"
      puts "1 いいえ, 2 はい (番号を入力して下さい)"
      i = gets.to_i
      case i
      when 1
        puts_field
        put_request
      when 2
        ask_continue?
      else
        puts "もう一度入力して下さい"
        ask_retire?
      end
    end

    def print_color(color)
      return "黒" if color == :black
      return "白" if color == :white
    end
end

Othello.new
