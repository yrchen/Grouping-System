# encoding: utf-8
class UsersController < ApplicationController
	layout 'groups'
	
	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		invited_code = params[:invited_code]
		
		# Rails.logger.debug("--------" + invited_code + "--------")
		if invited_code == "minemine"
			if @user.save
				session[:user_id] = @user.id
				redirect_to :controller => 'groups', :action => 'index'
			else
				render "new"
			end
		else
			flash.now.alert = "邀請碼錯誤"
			render "new"
		end
	end
	
end
