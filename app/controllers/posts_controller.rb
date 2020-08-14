class PostsController < ApplicationController

  get "/posts" do
    redirect "/login" if !logged_in?
    @user = User.find(session[:user_id])
    erb :'posts/index'
  end

  get "/posts/new" do
    flash[:alert] = "Please Log In to Write a Post"
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
    redirect "/posts/#{params[:id]}" if current_user != @post.user
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

end
