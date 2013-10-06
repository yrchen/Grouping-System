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
		Group.import(params[:file])
		User.import(params[:file])
		redirect_to root_url, notice: "資料已儲存"
	end
	
	# for tutor use only
	def manual_add_course
		check_is_tutor
		@course = Course.new
	end
	
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
	# -------------------------------------------
	
	# for tutor use only
	def manual_add_student
		check_is_tutor
		@user = User.new
	end
	
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
	# -------------------------------------------
	
	# seting school class group method
	def set_group
		check_is_tutor
		@group = Group.new
	end
	
	def create_group
		@group = Group.new(params[:group])
		# check whether already has this group
		@has_group = Group.where( :course_id => @group.course_id, :school_class_id => @group.school_class_id).first
		
		respond_to do |format|
			if !@has_group
				if @group.save
					format.html { redirect_to setGroup_path, notice: '分組設定完成' }
				else
					format.html { render action: "set_group" }
				end
			elsif @has_group.mode != nil
				format.html { redirect_to setGroup_path, notice: '該班級的這堂課已設好分組模式' }
			# not yet to choose mode
			else
				@has_group.mode = @group.mode
				@has_group.save
				format.html { redirect_to setGroup_path, notice: '分組設定完成' }
			end
    end
	end
	# -------------------------------------------
	
	# find what courses this school_class have
	def search_group
		check_is_tutor
		@group = Group.new
	end
	
	def view_class
		@g = Group.new(params[:group])
		
		respond_to do |format|
			if @g.school_class_id != nil
				@groups = Group.where(:school_class_id => @g.school_class_id)
				# Rails.logger.debug("--------"+@groups.size.to_s+"--------")
				format.html
			else
				format.html { redirect_to searchGroup_path, notice: '尚未選擇班級' }
			end
		end
	end
	
	def view_group
		@group = Group.find(params[:id])
	end
	# -------------------------------------------
	
	# avoid student key this path to view this page
	def check_is_tutor
		redirect_to groups_path, alert: "您沒有權限，請先登入" if current_user.school_class_id > -1
	end
end
