require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
		set :session_secret, "password_security"
  end

  get "/" do
    erb :home
  end

  get "/signup" do
    if logged_in?
      redirect "/posts"
    else
      erb :signup
    end
  end

  post "/signup" do
    if params.values.any? { |x| x == "" }
      redirect '/signup'
    else
      @user = User.create(params)
      session[:user_id] = @user.id
      redirect '/posts'
    end
  end

  get "/posts" do
    redirect "/login" if !logged_in?
    @user = User.find(session[:user_id])
    erb :'posts/index'
  end

  get "/login" do
    if logged_in?
      redirect "/posts"
    else
      erb :login
    end
  end

  post "/login" do
    @user = User.find_by(username: params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect "/posts"
    else
      redirect "/login"
    end
  end

  get "/logout" do
    session.clear
    redirect "/login"
  end

  get "/users/:slug" do
    @user = User.find_by_slug(params[:slug])
    erb :'users/index'
  end

  get "/posts/new" do
    redirect "/login" if !logged_in?
    @user = User.find(session[:user_id])
    erb :'posts/new'
  end

  post "/posts" do
    redirect "/posts/new" if params[:content].empty?
    @post = Post.create(title: params[:title], content: params[:content], user_id: session[:user_id])
    redirect "/posts"
  end

  get "/posts/:id" do
    redirect "/login" if !logged_in?
    @post = Post.find(params[:id])
    erb :'posts/show'
  end

  get "/posts/:id/edit" do
    redirect "/login" if !logged_in?
    @post = Post.find(params[:id])
    erb :'posts/edit'
  end

  patch "/posts/:id" do
    @post = Post.find(params[:id])
    redirect "/posts/#{@post.id}/edit" if params[:content].empty?
    @post.content = params[:content]
    @post.save
    redirect "/posts"
  end

  delete "/posts/:id" do
    @post = Post.find(params[:id])
    redirect "/posts/#{params[:id]}" if current_user != @post.user
    @post.delete
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
