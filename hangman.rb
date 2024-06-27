require 'msgpack'

class Hangman

  def initialize
    @alphabet = ("a".."z").to_a
    @word_to_find = self.load_word('words.txt')
    @guess_word = []
    @guessed_letters = []
    @word_to_find.length.times do
      @guess_word.push('_')
    end
  end

  def start_game
    @tries = 10
    flag = true
    puts 'Start new game: press 1'
    puts 'Load recent games: press 2'
    choice = gets.chomp.to_s
    if choice == '2'
      self.load_game
    elsif choice == '1'
      continue
    end
    puts 'Hangman Game has started'
    while flag do
      puts "You have #{@tries}"
      self.show_word
      puts 'You can save your game now type \'save\', to skip type skip'
      save_or_skip = gets.chomp.to_s
      if save_or_skip == 'save'
        self.save_game
        puts 'Your game is saved'
        return
      end
      puts "\nChoose letter from #{@alphabet}"
      self.ask_input
      flag = self.check_win
    end
  end

  def load_game
    puts 'Type save name'
    name = gets.chomp.to_s
    packed_data = File.read("saves/#{name}.msgpack")
    unpacked_data = MessagePack.unpack(packed_data)
    @alphabet = unpacked_data['alphabet'].to_a
    @word_to_find = unpacked_data['word_to_find'].to_s
    @guess_word = unpacked_data['guess_word'].to_a
    @guessed_letters = unpacked_data['guessed_letters'].to_a
    @tries = unpacked_data['tries'].to_i
  end

  def save_game
    Dir.mkdir('saves') unless Dir.exist?('saves')
    puts 'Type save name'
    name = gets.chomp.to_s
    filename = "saves/#{name}.msgpack"
    saved_game = {alphabet: @alphabet, word_to_find: @word_to_find, guess_word: @guess_word, guessed_letters: @guessed_letters, tries: @tries}.to_msgpack
    File.open(filename, 'wb') do |file|
      file.write(saved_game)
    end
  end

  def ask_input
    character = ''
    loop do
      character = gets.chomp.downcase
      break if character.is_a?(String) && character.length == 1 && @alphabet.include?(character)
    end
    self.put_letter(character)
    @alphabet.delete(character)
    character
  end

  def put_letter(letter)
    word = @word_to_find.split("")
    if word.include?(letter)
      word.each_with_index do |elem, index|
        if elem == letter
            @guessed_letters.push(letter)
            @guess_word[index] = letter
          end
      end
    else
      @tries -= 1
    end

  end

  def load_word(file)
    word = ''
    loop do
      word = File.readlines(file).sample.chomp
      break if word.length > 5 && word.length < 12
    end
    word
  end
end

def show_word
  puts @guess_word.join(' ')
end

def check_win
  if @tries == 0
    puts "You lost a game word was #{@word_to_find}"
    return false
  elsif @guessed_letters.length == @word_to_find.length
    puts "You won word was #{@word_to_find}"
    return false
  end
  true
end

game = Hangman.new
game.start_game
