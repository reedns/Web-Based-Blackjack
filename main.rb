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
        score += 11
        if score > 21
          score -= 10
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

  def win(msg)
    session[:money] += session[:bet]
    @win = "<strong>#{session[:player_name]} won!</strong> #{msg}. #{session[:player_name]} now has <strong>$#{session[:money]}</strong>"
  end

  def lose(msg)
    session[:money] -= session[:bet]
    @lose = "<strong>#{session[:player_name]} lost.</strong> #{msg}. #{session[:player_name]} now has <strong>$#{session[:money]}</strong>"
  end

  def push(msg)
    @push ="<strong>It's a push.</strong> #{msg}. #{session[:player_name]} still has <strong>$#{session[:money]}</strong>"
  end
end

before do
  @show_buttons = true
  @dealer_turn = false
  @play_again = false
end

get '/' do
  if session[:player_name]
    redirect '/bet'
  else
    redirect '/set_name'
  end
end

get '/set_name' do
  session[:money] = 500
  erb :set_name
end

post '/set_name' do
  if params[:player_name].empty?
    @error = "Name is required"
    halt erb(:set_name)
  end

  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/bet' do
  session[:bet] = nil
  if session[:money] == 0
    redirect '/game/end'
  else
    erb :bet
  end
end

post '/bet' do
  params[:bet] = params[:bet].to_i
  if params[:bet] == 0
    @error = "Must make a bet."
    halt erb(:bet)
  elsif params[:bet] > session[:money]
    @error = "Not enough money to bet that much."
    halt erb(:bet)
  end
  
  session[:bet] = params[:bet]
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
    lose("The dealer got blackjack.")
  elsif player_score == BLACKJACK
    win("You got blackjack!")
  elsif dealer_score == BLACKJACK && player_score == BLACKJACK
    push("You got blackjack and dealer got blackjack.")
  end

  erb :game
end

post '/game/player/hit' do
  session[:player_cards] << session[:deck].pop
  if calculate(session[:player_cards]) > BLACKJACK
    lose("#{session[:player_name]} busted with a score of #{calculate(session[:player_cards])}.")
    @play_again = true
    @show_buttons = false
    session[:turn] = "dealer"
  end
  erb :game, layout: false
end

post '/game/player/stay' do
  @success = "You chose to stay."
  redirect '/game/dealer'
end

get '/game/dealer' do
  session[:turn] = "dealer"
  @show_buttons = false
  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])
  
  if dealer_score > BLACKJACK
    win("the dealer busted with a score of #{dealer_score}!")
    @play_again = true
  elsif dealer_score < MINIMUM_HIT || dealer_score < player_score  
    @dealer_turn = true
  else
    redirect '/game/compare'
  end

  erb :game, layout: false
end

post '/game/dealer/hit' do
  session[:dealer_cards] << session[:deck].pop
  redirect '/game/dealer'
end

get '/game/compare' do
  @play_again = true
  @show_buttons = false
  dealer_score = calculate(session[:dealer_cards])
  player_score = calculate(session[:player_cards])

  if player_score > dealer_score
    win("#{session[:player_name]} had #{player_score} and the dealer had #{dealer_score}")
  elsif player_score < dealer_score
    lose("#{session[:player_name]} had #{player_score} and the dealer had #{dealer_score}")
  else
    push("#{session[:player_name]} had #{player_score} and the dealer had #{dealer_score}")
  end

  erb :game, layout: false
end

get '/game/end' do
  if session[:money] == 0
    erb :broke
  else
    erb :end
  end
end




