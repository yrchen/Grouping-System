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
	
	# to store school class excel
	def import_excel
		SchoolClass.import(params[:file])
		Course.import(params[:file])
		User.import(params[:file])
		UserCourseRelationship.import(params[:file])
		redirect_to root_url, :flash => { :success => "資料已儲存" }
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
					format.html { redirect_to root_url, :flash => { :success => '課程新增成功' } }
				else
					format.html { render action: "manual_add_course" }
				end
			elsif( @course.name == nil || @course.name == "" )
				format.html { redirect_to macourse_path, :flash => { :error => '課程名稱不能為空白' } }
			elsif has_course
				format.html { redirect_to macourse_path, :flash => { :info => '此課程已存在' } }
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
					format.html { redirect_to root_url, :flash => { :success => '學生新增成功' } }
				else
					format.html { render action: "manual_add_student" }
				end
			elsif( @user.account == nil || @user.account == "" )
				format.html { redirect_to mastudent_path, :flash => { :error => '學號不能為空白' } }
			elsif( @user.name == nil || @user.name == "" )
				format.html { redirect_to mastudent_path, :flash => { :error => '姓名不能為空白' } }
			elsif has_user
				format.html { redirect_to mastudent_path, :flash => { :info => '該學生已存在' } }
			end
    end
	end
	# -------------------------------------------
	
	# seting school class group method
	def set_group
		check_is_tutor
		@course = Course.new
	end
	
	def create_group
		@course = Course.new(params[:course])
		# check whether already has this group
		@has_course = Course.where(  :name => @course.name ).first
		
		respond_to do |format|
			if @course.group_mode != nil
				if @has_course
					if @has_course.group_mode == nil
						@has_course.group_mode = @course.group_mode
						@has_course.save
						format.html { redirect_to setGroup_path, :flash => { :success => '分組設定完成' } }
					else
						format.html { redirect_to setGroup_path, :flash => { :warning => '該班級的這堂課已設好分組模式' } }
					end
				else
					format.html { redirect_to setGroup_path, :flash => { :warning => '尚未選擇班級' } }
				end
			else
				format.html { redirect_to setGroup_path, :flash => { :warning => '尚未選擇模式' } }
			end
    end
	end
	# -------------------------------------------
	
	# find what courses this school_class have
	def search_group
		@course = Course.new
		@course_list = []
		@UC_ship = UserCourseRelationship.where(:user_id => current_user.id)
		@UC_ship.each do |s|
			@course_list << Course.find(s.course_id)
		end
	end
	
	def view_class
		@course = Course.new(params[:course])
		@has_course = Course.find_by_name(@course.name)
		@tasks = []
		
		respond_to do |format|
			if @has_course
				@tasks = Task.where(:course_id => @has_course.id).order("created_at DESC")
				format.html
			else
				format.html { redirect_to searchGroup_path, :flash => { :warning => '尚未選擇班級' } }
			end
		end
	end
	# -------------------------------------------
	
	# setting course
	def	choose_course
		@course = Course.new
		
		# for student: see courses which they join
		@UCRs = UserCourseRelationship.where(:user_id => current_user.id)
		@courses = []
		@UCRs.each do |c|
			@courses << Course.find(c.course_id)
		end
	end
	
	def set_course
		check_is_tutor
		@course = Course.new(params[:course])
		@has_course = Course.where( :name => @course.name ).first
		
		if @has_course
			@course = @has_course
			@has_UC_ship = UserCourseRelationship.where( :course_id => @course.id, :user_id => current_user.id ).first
		else
			format.html { redirect_to chooseCourse_path, :flash => { :warning => '查無此課程' } }
		end
	end
	
	def set_tutor
		check_is_tutor
		@UC_ship = UserCourseRelationship.new
		@UC_ship.user_id = current_user.id
		@UC_ship.course_id = params[:c_id]
	
		respond_to do |format|
			if @UC_ship.save
				format.html { redirect_to chooseCourse_path, :flash => { :success => '指導員設定完成' } }
			else
				format.html { redirect_to chooseCourse_path, :flash => { :error => '指導員設定失敗' } }
			end
		end
	end
	
	def remove_tutor
		check_is_tutor
		@has_UC_ship = UserCourseRelationship.where(  :course_id => params[:c_id], :user_id => current_user.id ).first
	
		respond_to do |format|
			if @has_UC_ship
				@has_UC_ship.destroy
				format.html { redirect_to chooseCourse_path, :flash => { :success => '指導員退出完成' } }
			else
				format.html { redirect_to chooseCourse_path, :flash => { :error => '指導員退出失敗' } }
			end
		end
	end
	
	def choose_student
		check_is_tutor
	
		@user = User.new
		@course = Course.find( params[:c_id] )
	end
	
	def add_student_to_course
		check_is_tutor
		@has_user = User.where( :account => params[:user_account] ).first

		respond_to do |format|
			if !@has_user
				format.html { redirect_to chooseCourse_path, :flash => { :warning => '查無此學生' } }
			else
				@has_UC_ship = UserCourseRelationship.where(  :course_id => params[:c_id], :user_id => @has_user.id ).first
				if @has_UC_ship
					format.html { redirect_to chooseCourse_path, :flash => { :warning => '學生已加過此課程' } }
				else
					@UC_ship = UserCourseRelationship.new
					@UC_ship.user_id = @has_user.id
					@UC_ship.course_id = params[:c_id]
					
					if @UC_ship.save
						format.html { redirect_to chooseCourse_path, :flash => { :success => '學生加入成功' } }
					else 
						format.html { redirect_to chooseCourse_path, :flash => { :error => '學生加入失敗' } }
					end
				end
			end
		end
	end
	# -------------------------------------------
	
	# student view course
	def view_course
		@course = Course.new(params[:course])
		@has_course = Course.where( :name => @course.name ).first
		@tasks = Task.where(:course_id => @has_course.id).order("created_at DESC")
	end
	# -------------------------------------------
	
	def rate
    @group = Group.find(params[:id])
    @group.rate(params[:stars], current_user)
    respond_to do |format|
        format.js   {}
    end
  end
	
	# avoid student key this path to view this page
	def check_is_tutor
		redirect_to groups_path, alert: "很抱歉，您沒有權限閱覽該頁面" if current_user.school_class_id > -1
	end
end
