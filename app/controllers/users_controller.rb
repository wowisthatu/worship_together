class UsersController < ApplicationController
  before_action :ensure_user_logged_in, only: [:edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_admin, only: [:destroy]
  before_action :ensure_user_not_logged_in, only: [:new, :create]
  before_action :check_for_self_deletion, only: [:destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the site, #{@user.name}"
      redirect_to @user
    else
      flash.now[:danger] = "Unable to create new user"
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id]) 
  end

  def update
    @user = User.find(params[:id]) 
    if @user.update_attributes(user_params)
      flash[:success] = "Information updated successfully."
      redirect_to(user_path)
    else
      flash[:danger] = "Something went wrong"
    end
  end

  def destroy
    @user = User.find(params[:id]) 
    @user.destroy
    flash[:success] = "User deleted successfully"
    redirect_to(users_path)

  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def ensure_user_logged_in
    unless current_user
      flash[:warning] = 'Not logged in'
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to root_path
    end
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def ensure_admin
    unless current_user.admin?
      flash[:danger] = 'Only admins allowed to delete users'
      redirect_to root_path
    end
  end

  def ensure_user_not_logged_in
    if current_user
      redirect_to root_path
      flash[:warning] = 'Logged in users cannot do that'
    end
  end

  def check_for_self_deletion
    @user = User.find(params[:id]) 
    if current_user?(@user)
      flash[:danger] = "You deleted yourself"
      redirect_to(root_path)
    end
  end
end
