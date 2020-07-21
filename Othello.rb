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
      mode_select
    end
  end

  def select_your_color
    puts "どちらにしますか？番号を入力して下さい"
    puts "1 黒番, 2 白番"
    i = gets.to_i
    puts "ゲームを終了したい場合は、endまたはexitと入力して下さい。"
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

  def ask_retire?
    puts "本当にゲームを終了しますか？"
    puts "1 はい, 2 いいえ (番号を入力して下さい)"
    i = gets.to_i
    case i
    when 1
      ask_continue?
    when 2
      board.puts_field
      put_request
    else
      puts "もう一度入力して下さい"
      ask_retire?
    end
  end

  def man_vs_man
    man_turn
    return ask_continue? if board.game_set?
    man_vs_man
  end

  def man_vs_computer
    man_turn
    return ask_continue? if board.game_set?
    computer_turn
    return ask_continue? if board.game_set?
    man_vs_computer
  end

  def computer_vs_man
    computer_turn
    return ask_continue? if board.game_set?
    man_turn
    return ask_continue? if board.game_set?
    computer_vs_man
  end

  def computer_vs_computer
    computer_turn
    return ask_continue? if board.game_set?
    computer_vs_computer
  end

  def man_turn
    put_request
    board.next_turn
    board.current_judge
    board.puts_field
  end

  def computer_turn
    board.auto_put_piece
    board.next_turn
    board.current_judge
    board.puts_field
  end

  def put_request
    print "縦 横: "
    i,j = gets.split
    return ask_retire? if i == "end" || i == "exit"
    if i.nil? || j.nil?
      puts "もう一度入力して下さい"
      return put_request
    end
    put_request unless board.put_piece(i.to_i,j.to_i)
  end
end

Othello.new
