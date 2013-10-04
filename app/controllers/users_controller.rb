# encoding: utf-8
class UsersController < ApplicationController
	layout 'groups'
	
	def new
		@user = User.new
	end

	def create
		@user = User.new(params[:user])
		
		if @user.save
			session[:user_id] = @user.id
			redirect_to :controller => 'groups', :action => 'index', :notice => "註冊成功!"
		else
			render "new"
		end
	end
	
end
