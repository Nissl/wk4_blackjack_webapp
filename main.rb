require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  "Hello Tealeaf, I'll be putting my blackjack game here soon enough. Shotgun is up and running."
end

get '/template' do
  #layout.erb targeted by default unless otherwise specified
  erb :demo_template
end

get '/nested_template' do
  erb :"/users/profile"
end

get '/bad_link' do
  redirect '/'
end