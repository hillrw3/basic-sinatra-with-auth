require "sinatra"
require "rack-flash"

require "./lib/user_database"

class App < Sinatra::Application
  enable :sessions
  use Rack::Flash

  def initialize
    super
    @user_database = UserDatabase.new
  end

  get "/" do
    if session[:user]
      @user = session[:user][0]
      erb :logged_in_homepage
    else
      erb :homepage
    end
  end

  get "/registration" do
    erb :registration
  end

  post "/registration" do
    username = params[:username]
    password = params[:password]
    @user_database.insert({:username => username, :password => password})
    flash[:notice] = "Thank you for registering"
    redirect '/'
  end

  post '/login' do
    active_user = @user_database.all.select do |user_hashes|
      user_hashes[:username] == params[:username] && user_hashes[:password] == params[:password]
    end
    unless active_user == []
      session[:user] = active_user
    else
      flash[:notice] = "User not found"
    end
    redirect to "/"
  end

  post '/logout' do
    session[:user] = nil
    redirect to '/'
  end
end
