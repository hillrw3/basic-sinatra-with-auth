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
      @user = @user_database.find(session[:user])
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
    if username == "" && password == ""
      flash[:registration_error] = "No username or password entered"
    elsif password == ""
      flash[:registration_error] = "No password entered"
    elsif username == ""
      flash[:registration_error] = "No username entered"
    else
      @user_database.insert({:username => username, :password => password})
      flash[:notice] = "Thank you for registering"
      redirect '/'
    end
    redirect back
  end

  post '/login' do
    active_user = @user_database.all.find do |user_hashes|
      user_hashes[:username] == params[:username] && user_hashes[:password] == params[:password]
    end
    if active_user
      session[:user] = active_user[:id]
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
