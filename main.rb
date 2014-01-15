require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

module Constants
  MAX_SCORE = 21
  DEALER_CUTOFF = 17
end

helpers do
  include Constants
  def card_route(card)
    "/images/cards/#{card[1].downcase}_#{card[0].downcase}.jpg"
  end

  def score(hand)
    total = 0
    vals = hand.map { |card| card[0] }
    vals.each do |val|
      if val == 'Ace'
        total += 11
      else
        total += (val.to_i == 0 ? 10 : val.to_i)
      end
    end

    vals.select { |val| val == 'Ace' }.count.times do
      total -= 10 if total > Constants::MAX_SCORE
    end

    total
  end

  def setup_game
    deck = []
    values = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
    suits = %w(Clubs Diamonds Hearts Spades)
    deck = values.product(suits)
    session[:deck] = deck.shuffle!
    session[:user_cards] = [session[:deck].pop]
    session[:dealer_cards] = [session[:deck].pop]
    session[:user_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
    session[:dealer_hitting] = false
    session[:dealer_finished] = false
  end

  def reset_game
    session[:user_name] = nil
    session[:user_money] = nil
    session[:user_bet] = nil
  end
end

get '/' do
  reset_game
  redirect '/get_name'
end

get '/get_name' do
  erb :get_name
end

post '/set_name' do
  session[:user_name] = params[:user_name]
  redirect '/get_money'
end

get '/get_money' do
  erb :get_money
end

post '/set_money' do
  session[:user_money] = params[:money].to_i
  redirect '/get_bet'
end

get '/get_bet' do
  if !session[:user_money]
    redirect '/get_stakes'
  end
  setup_game
  erb :get_bet
end

post '/set_bet' do
  session[:user_bet] = params[:bet].to_i
  redirect '/game'
end

get '/game' do
  #Check for blackjacks - specialized conditions not implemented yet.
  if (score(session[:user_cards]) == Constants::MAX_SCORE && 
      session[:user_cards].length == 2)
    if score(session[:dealer_cards]) == Constants::MAX_SCORE
      @blackjack = true
      @game_draw = true
    else
      @blackjack = true
      @user_wins = true
      session[:user_money] += session[:user_bet] * 3 / 2
    end
  elsif (score(session[:dealer_cards]) == Constants::MAX_SCORE && 
    session[:dealer_cards].length == 2)
    @blackjack = true
    @user_loses = true
    session[:user_money] -= session[:user_bet]
  end

  # If the user busted, show results
  if score(session[:user_cards]) > Constants::MAX_SCORE
    @user_busts = true
    @user_loses = true
    session[:user_money] -= session[:user_bet]
  end

  # If we've already finished the game, show results
  if (score(session[:dealer_cards]) >= Constants::DEALER_CUTOFF && 
      session[:dealer_finished])
    if score(session[:dealer_cards]) > Constants::MAX_SCORE
      @dealer_busts = true
      @user_wins = true
      session[:user_money] += session[:user_bet]
    elsif score(session[:dealer_cards]) < score(session[:user_cards])
      @user_wins = true
      session[:user_money] += session[:user_bet]
    elsif score(session[:dealer_cards]) == score(session[:user_cards])
      @game_draw = true
    else
      @user_loses = true
      session[:user_money] -= session[:user_bet]
    end
  end
  erb :game
end

post '/hit' do
  session[:user_cards] << session[:deck].pop
  redirect '/game'
end

post '/stay' do
  if score(session[:dealer_cards]) < Constants::DEALER_CUTOFF
    session[:dealer_hitting] = true 
    erb :game
  else
    session[:dealer_hitting] = false
    session[:dealer_finished] = true
    redirect '/game'
  end
end

post '/dealer_hit' do
  session[:dealer_cards] << session[:deck].pop
  if score(session[:dealer_cards]) < Constants::DEALER_CUTOFF
    erb :game
  else
    session[:dealer_hitting] = false
    session[:dealer_finished] = true
    redirect '/game'
  end
end

post '/quit' do
  erb :quit
end

