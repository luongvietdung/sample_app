class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def edit
  end
  def create
    user = User.find_by(email: params[:password_reset][:email])
    unless user.nil?
      user.send_email_password_reset
      flash[:info] = "Email send with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found!"
      render 'new'
    end    
  end
  def update
    if params[:user][:password].empty?
      flash.now[:danger] = "Password can't empty"
      render 'edit'
    elsif @user.update_attributes(user_params)
      flash[:success] = "Password has been reset"
      log_in @user
      redirect_to @user
    end
  end
  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    def get_user
      @user = User.find_by(email: params[:email])
    end
    def valid_user
      unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
        redirect_to root_url
       end 
    end
    def check_expiration
      if @user. password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end 
    end
end
