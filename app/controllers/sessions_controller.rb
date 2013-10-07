# encoding: utf-8
class SessionsController < ApplicationController
	layout 'groups'
	
  def new
  end
	
	def create
		user = User.find_by_account(params[:account])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect_to root_url
		else
			# Rails.logger.debug("--------In controller create else--------")
			flash.now.alert = "帳號或密碼錯誤"
			render "new"
		end
	end
	
	def destroy
		session[:user_id] = nil
		redirect_to root_url
	end
	
	# change password
	def new_password
	end
	
	def change_password
		old_pwd = params[:old_password]
		pwd = params[:password]
		pwd_confirm = params[:password_confirmation]
		@user = User.find( session[:user_id] )
		
		# Rails.logger.debug("--------" + pwd.blank? + "--------")
		
		if !@user.authenticate(old_pwd)
			redirect_to newPassword_path, notice: "密碼輸入錯誤"
		else
			if old_pwd == pwd
				redirect_to newPassword_path, notice: "新舊密碼相同"
			elsif pwd.blank? || pwd_confirm.blank? || pwd != pwd_confirm
				redirect_to newPassword_path, notice: "新密碼驗證有誤"
			else
				@user.password = pwd
				@user.password_confirmation = pwd_confirm
				@user.save
				redirect_to root_url, notice: "密碼已變更"
			end
		end
	end
	# --------------------------------------------
end
