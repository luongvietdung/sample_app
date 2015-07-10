module SessionsHelper
	def log_in(user)
		session[:user_id] = user.id
	end

	def current_user
		if (user_id = session[:user_id])
			@current_user ||= User.find_by(id: user_id)
		elsif (user_id = cookies.signed[:user_id])
			user = User.find_by(id: user_id)
			if user && user.authenticated?(cookies[:remember_token])
				log_in user
				@current_user = user
			end
		end
	end

	def logged_in?
		!current_user.nil?
	end

	# Rememer user
	def remember(user)
		user.remember # Tao token, encryot va cap nhat CSDL
		cookies.permanent.signed[:user_id] = user.id
		cookies.permanent[:remember_token] = user.remember_token
	end

	def fogot(user)
		cookies.delete :user_id
		cookies.delete :remember_token
		user.forgot
	end

	def log_out
		fogot current_user
		session.delete :user_id
	end
end
