require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK = 21
MINIMUM_HIT = 17

helpers do
  def calculate(cards)
    values = cards.map { |card| card[1] }

    score = 0
    values.each do |value|
      if value == 'Ace'
        if score < 11
          score += 11
        else
          score += 1
        end
      elsif value.to_i == 0
        score += 10
      else
        score += value.to_i
      end  
    end
    score    
  end

  def show_image(card)
    suit = card[0]
    value = card[1]
    "<img src='/images/cards/#{suit.downcase}_#{value.downcase}.jpg' class='card_img'>"
  end

  def hide_card(card)
    suit = card[1][0]
    value = card[1][1]
    "<img src='/images/cards/#{suit.downcase}_#{value.downcase}.jpg' class='card_img'>"
  end
end


before do
  @show_buttons = true
  @dealer_turn = false
  @play_again = false
  #@hide_dealer_hand = true
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end

  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  session[:turn] = session[:player_name]

  suits = ["Diamonds", "Spades", "Hearts", "Clubs"]
  values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", 'Jack', 'Queen', 'King', 'Ace']
  session[:deck] = suits.product(values).shuffle!
  
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop

  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])
  if player_score == BLACKJACK || dealer_score == BLACKJACK
    redirect '/game/blackjack'
  end
    
  erb :game
end

get '/game/blackjack' do
  session[:turn] = "dealer"
  @show_buttons = false
  @play_again = true
  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])

  if dealer_score == BLACKJACK
    @error = "The dealer got blackjack"
  elsif player_score == BLACKJACK
    @success = "You got blackjack!"
  elsif dealer_score == BLACKJACK && player_score == BLACKJACK
    @error = "Push"
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate(session[:player_cards]) > BLACKJACK
    @error = "Oh no! You busted."
    @show_buttons = false
    @play_again = true
    session[:turn] = "dealer"
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You chose to stay."
  redirect '/game/dealer/turn'
end

get '/game/dealer/turn' do
  session[:turn] = "dealer"
  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])

  if dealer_score < MINIMUM_HIT || dealer_score < player_score  
    @dealer_turn = true
  else
    redirect '/game/compare'
  end

  erb :game
end

post '/game/dealer/hit' do
  @show_buttons = false

  session[:dealer_cards] << session[:deck].pop
  if calculate(session[:dealer_cards]) > BLACKJACK
    @success = "Dealer busted! You win!"
    @play_again = true
  else
    redirect '/game/dealer/turn'
  end

  erb :game
end

get '/game/compare' do
  @play_again = true
  @show_buttons = false
  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])

  if player_score > dealer_score
    @success = "Congratulations, #{session[:player_name]}! You won!"
  elsif player_score < dealer_score
    @error = "I'm sorry #{session[:player_name]}. The dealer won."
  else
    @success = "It's a push..."
  end

  erb :game
end

get '/game/end' do
  erb :end
end






