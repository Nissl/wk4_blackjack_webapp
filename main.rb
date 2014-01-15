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

  def setup_game
    deck = []
    values = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
    suits = %w(Clubs Diamonds Hearts Spades)
    session[:deck] = values.product(suits).shuffle!
    session[:user_cards] = [session[:deck].pop]
    session[:dealer_cards] = [session[:deck].pop]
    session[:user_cards] << session[:deck].pop
    session[:dealer_cards] << session[:deck].pop
    session[:dealer_hitting] = false
    session[:dealer_finished] = false
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

  def card_route(card)
    "/images/cards/#{card[1].downcase}_#{card[0].downcase}.jpg"
  end

  def user_wins
    session[:user_money] += session[:user_bet]
    @user_wins = true
  end

  def user_loses
    session[:user_money] -= session[:user_bet]
    @user_loses = true
  end
end

get '/' do
  if session[:user_name]
    redirect '/get_money'
  else
    redirect '/get_name'
  end
end

get '/change_player' do
  session.clear
  redirect '/'
end

get '/get_name' do
  erb :get_name
end

post '/set_name' do
  if params[:user_name].empty?
    @error = "You need to enter a name!"
    halt erb(:get_name)
  else
    session[:user_name] = params[:user_name]
    redirect '/get_money'
  end
end

get '/get_money' do
  erb :get_money
end

post '/set_money' do
  unless params[:money].to_i > 0
      @error = "You must buy in to play!"
      erb(:get_money)
  else
    session[:user_money] = params[:money].to_i
    redirect '/get_bet'
  end
end

get '/get_bet' do
  unless session[:user_money]
    redirect '/get_money'
  end
  erb :get_bet
end

post '/set_bet' do
  if params[:bet].empty?
    @error = "You must bet to play!"
    halt erb(:get_bet)
  elsif params[:bet].to_i == 0
    @error = "No bet input"
    halt erb(:get_bet)
  elsif params[:bet].to_i > session[:user_money]
    halt erb(:bad_bet)
  else
    session[:user_bet] = params[:bet].to_i
    setup_game
    redirect '/game'
  end
end

get '/game' do
  #Check for blackjacks - specialized conditions not implemented yet.
  if (score(session[:user_cards]) == Constants::MAX_SCORE && 
      session[:user_cards].length == 2)
    @blackjack = true
    if score(session[:dealer_cards]) == Constants::MAX_SCORE
      @game_draw = true
    else
      @user_wins = true
      session[:user_money] += session[:user_bet] * 3 / 2
    end
  elsif (score(session[:dealer_cards]) == Constants::MAX_SCORE && 
    session[:dealer_cards].length == 2)
    user_loses
    @blackjack = true
  end

  # If the user busted, show results
  if score(session[:user_cards]) > Constants::MAX_SCORE
    user_loses
    @user_busts = true
  end

  # If we've already finished the game, show results
  if (score(session[:dealer_cards]) >= Constants::DEALER_CUTOFF && 
      session[:dealer_finished])
    if score(session[:dealer_cards]) > Constants::MAX_SCORE
      user_wins
      @dealer_busts = true
    elsif score(session[:dealer_cards]) < score(session[:user_cards])
      user_wins
    elsif score(session[:dealer_cards]) == score(session[:user_cards])
      @game_draw = true
    else
      user_loses
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
  else
    session[:dealer_hitting] = false
    session[:dealer_finished] = true
  end
  redirect '/game'
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

