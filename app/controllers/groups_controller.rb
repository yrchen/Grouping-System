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
	
	# view import html
	def import
		check_is_tutor
	end
	
	# to store excel
	def import_excel
		SchoolClass.import(params[:file])
		Course.import(params[:file])
		User.import(params[:file])
		redirect_to root_url, notice: "資料已匯入"
	end
	
	# for tutor use only
	def manual_add_course
		check_is_tutor
		@course = Course.new
	end
	
  # POST
  def create_course
		@course = Course.new(params[:course])
		# to check already has course
		has_course = Course.find_by_name(@course.name)
		
    respond_to do |format|
			if( @course.name != nil && @course.name != "" && !has_course )
				if @course.save
					format.html { redirect_to root_url, notice: '課程新增成功' }
				else
					format.html { render action: "manual_add_course" }
				end
			elsif( @course.name == nil || @course.name == "" )
				format.html { redirect_to macourse_path, notice: '課程名稱不能為空白' }
			elsif has_course
				format.html { redirect_to macourse_path, notice: '此課程已存在' }
			end
    end
	end
	
	# for tutor use only
	def manual_add_student
		check_is_tutor
		@user = User.new
	end
	
  # POST
  def create_student
		@user = User.new(params[:user])
		# to check already has student
		has_user = User.find_by_account(@user.account)
		
    respond_to do |format|
			if( @user.account != nil && @user.account != "" && !has_user )
				@user.password = "1111"
				if @user.save
					format.html { redirect_to root_url, notice: '學生新增成功' }
				else
					format.html { render action: "manual_add_student" }
				end
			elsif( @user.account == nil || @user.account == "" )
				format.html { redirect_to mastudent_path, notice: '學號不能為空白' }
			elsif has_user
				format.html { redirect_to mastudent_path, notice: '該學生已存在' }
			end
    end
	end
	
	# avoid student key this path to view this page
	def check_is_tutor
		redirect_to groups_path, alert: "您沒有權限，請先登入" if current_user.class_id != -1
	end
end
