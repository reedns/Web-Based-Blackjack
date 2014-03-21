require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  erb :set_name
end

post '/set_name' do
  session[:player_name] = params[:player_name]
  redirect '/game'
end

get '/game' do
  erb :game
end

get '/nested_template' do
  erb :"Users/profile"
end
