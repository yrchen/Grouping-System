# encoding: utf-8
class GroupsController < ApplicationController
	before_filter :authorize, except: [:index]
	
	def welcome
	end
	
	def index
		# if we get account value mean that user type his account and password, then we 'post' those value to 'session controller'
		if params[:account]
			user = User.find_by_account(params[:account])
			if user && user.authenticate(params[:password])
				session[:user_id] = user.id
				redirect_to :controller => 'groups', :action => 'index'
				# Rails.logger.debug("--------In controller create--------")
			else
				flash.now.alert = "帳號或密碼錯誤"
				render :controller => 'groups', :action => 'index'
			end
		end
	end
end
