# encoding: utf-8
class SessionsController < ApplicationController
	layout 'groups'
	
  def new
  end
	
	def create
		user = User.find_by_account(params[:account])
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect_to :controller => 'groups', :action => 'index', notice: "Logged in!"
			# Rails.logger.debug("--------In controller create--------")
		else
			# Rails.logger.debug("--------In controller create else--------")
			flash.now.alert = "帳號或密碼錯誤"
			render "new"
		end
	end
	
	def destroy
		session[:user_id] = nil
		redirect_to :controller => 'groups', :action => 'index', notice: "登出"
	end
end
