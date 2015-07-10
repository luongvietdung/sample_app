class SessionsController < ApplicationController
	def new		
	end

	def create
		@user = User.find_by(email: params[:session][:email])
		if @user && @user.authenticate(params[:session][:password])
			#login success
			log_in @user
			params[:session][:remember] == "1" ? remember(@user) : fogot(@user)
			redirect_to root_url
		else
			#login fail
			flash[:danger] = "Email or password incorrect!"
			render 'new'
		end
	end

	def destroy
		log_out if logged_in?
		redirect_to root_url
	end
end
