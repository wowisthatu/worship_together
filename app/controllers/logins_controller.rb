class LoginsController < ApplicationController
  before_action :check_for_session, only: [:new]
  
  def new
  end

  def create
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      flash[:success] = 'Logged in'
      session[:user_id] = user.id
      redirect_to users_path
    else
      flash.now[:danger] = 'Invalid username or password'
      render 'new'
    end
  end

  def destroy
    flash[:info] = 'Logged out'
    session[:user_id] = nil
    redirect_to users_path
  end
  
  def check_for_session
    if session[:user_id] != nil
      redirect_to users_path
      flash[:danger] = 'You are already logged in'
    end
  end
end
