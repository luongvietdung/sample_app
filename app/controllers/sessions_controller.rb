class SessionsController < ApplicationController
  def new

  end
  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		#login success
  		params[:session][:remember_me] == 1 ? remember(user) : forget(user)
  		log_in user
  		remember user
  		redirect_to user
  	else
  		flash[:danger] = "Invalid email / password combination"
  		render 'new'
  	end
  end
end
