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
    erb :homepage
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
end
