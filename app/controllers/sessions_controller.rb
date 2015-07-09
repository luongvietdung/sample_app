class SessionsController < ApplicationController
  def new

  end
  def create
  	user = User.find_by(email: params[:session][:email].downcase)
  	if user && user.authenticate(params[:session][:password])
  		#login success
      if user.activated?
    		params[:session][:remember_me] == 1 ? remember(user) : forget(user)
    		log_in user
    		remember user
    		redirect_to_back_or user 
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
  	else
  		flash[:danger] = "Invalid email / password combination"
  		render 'new'
  	end
  end
  def destroy
  	log_out
  	redirect_to root_url
  end
end
