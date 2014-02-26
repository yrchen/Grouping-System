# encoding: utf-8
class TasksController < ApplicationController
	layout 'groups'
	
	def new
		check_is_tutor
		@task = Task.new
	end
	
	def create
		check_is_tutor
		@task = Task.new(params[:task])
		
		# note that 'deadline' store into database will turn into america timezone
		respond_to do |format|
			if(@task.title == "" || @task.category == nil)
				format.html { redirect_to chooseCourse_path, :flash => { :error => '各個欄位皆不能留白' } }
			else
				if @task.save
					format.html { redirect_to chooseCourse_path, :flash => { :success => '文章發表成功' } }
				else
					format.html { redirect_to chooseCourse_path, :flash => { :error => '文章發表失敗' } }
				end
			end
		end
	end
	
	def index
		@tasks = Task.where(:course_id => params[:c_id]).order("created_at DESC")
	end
	
	def show
		@task = Task.find(params[:id])
		@groups = @task.groups.order("inclass_number ASC")
		# @groups = Group.where(:task_id => @task.id)
		
		@upload = Upload.where(:task_id => @task.id, :user_id => current_user.id).first || Upload.new
		if @upload.id == nil
			@upload.task_id = @task.id
			@upload.user_id = current_user.id
		end
		
		if @groups.size > 0 && current_user.school_class_id >= 0
			# To find this user's group in this task
			# First, find all this user's groups in database
			@user_groups = current_user.student_group_relationships
			@current_group = []
			@user_groups.each do |u|
				if @groups.where(:id => u.group_id).first
					# this user's group in this task
					@current_group = @groups.where(:id => u.group_id).first
					break
				end
			end
			
			# To find teammates, save in '@teammates'
			@team = []
			@teammates = []
			@rate_list = []
			if @current_group != nil && @current_group != []
				print '---------------'+@current_group
				@team = StudentGroupRelationship.where(:group_id => @current_group.id)
				@team.each do |t|
					if t.user.id != current_user.id
						@teammates << t.user
						
						# rating teammates
						@member_rate = MemberRate.where(:task_id => @task.id, :from_id => current_user.id, :to_id => t.user.id).first || MemberRate.new(:task_id => @task.id, :from_id => current_user.id, :to_id => t.user.id)
						@member_rate.save
						@rate_list << @member_rate
						@mate = Rate.where(:rater_id => current_user.id, :rateable_id => @member_rate.id, :rateable_type => 'MemberRate').first || Rate.new(:rater_id => current_user.id, :rateable_id => @member_rate.id, :rateable_type => 'MemberRate', :stars => 0)
						@mate.save
						@member_rate.rate_id = @mate.id
						@member_rate.save
					end
				end
				
				# rating grouping result
				@grouping_rate = Rate.where(:rater_id => current_user.id, :rateable_id => @current_group.id, :rateable_type => 'Group').first || Rate.new(:rater_id => current_user.id, :rateable_id => @current_group.id, :rateable_type => 'Group', :stars => 3)
				@grouping_rate.save
			end
		end
	end
	
	def edit
		check_is_tutor
		@task = Task.find(params[:id])
	end
	
	def update
		check_is_tutor
		@task = Task.find(params[:id])
		@tmp = Task.new(params[:task])
		
		# note that 'deadline' store into database will turn into america timezone
		respond_to do |format|
			if(@tmp.title == "" || @tmp.category == nil)
				format.html { redirect_to chooseCourse_path, :flash => { :error => '各個欄位皆不能留白' } }
			else
				if @task.update_attributes(params[:task])
					format.html { redirect_to chooseCourse_path, :flash => { :success => '文章編輯成功' } }
				else
					format.html { redirect_to chooseCourse_path, :flash => { :error => '文章編輯失敗' } }
				end
			end
		end
	end
	
	def destroy
		check_is_tutor
		@task = Task.find(params[:id])
		
		respond_to do |format|
			if @task.destroy
				format.html { redirect_to chooseCourse_path, :flash => { :success => '公告成功刪除' } }
			else
				format.html { redirect_to chooseCourse_path, :flash => { :error => '公告刪除失敗' } }
			end
		end
	end
	
	# import grouping excel
	def import_group
		check_is_tutor
		@task = Task.find(params[:id])
		@groups = Group.where(:task_id => @task.id)
	end
	
	def group_excel
		check_is_tutor
		Group.import(params[:id], params[:file])
		StudentGroupRelationship.import(params[:id], params[:file])
		
		redirect_to root_url, :flash => { :success => "資料已儲存" }
	end
	# -------------------------------------------
	
	# import student's grade excel
	def import_score
		check_is_tutor
		@task = Task.find(params[:id])
	end
	
	def	score_excel
		check_is_tutor
		Upload.import(params[:id], params[:file])
		
		redirect_to root_url, :flash => { :success => "資料已儲存" }
	end
	# -------------------------------------------
	
	def view_group
		@task = Task.find(params[:id])
		@groups = @task.groups.order("inclass_number ASC")
		
		if @groups.size == 0
			redirect_to searchGroup_path, :flash => { :info => "此公告並無分組" }
		end
	end
	
	def	remove_group
		@groups = Group.where(:task_id => params[:id])
		t_id = params[:id]
		
		@groups.each do |g|
			@SG_ships = StudentGroupRelationship.where(:group_id => g.id)
			if @SG_ships.size > 0
				@SG_ships.delete_all
			end
		end
		
		respond_to do |format|
			if @groups.delete_all
				format.html { redirect_to importGroup_path(:id => t_id), :flash => { :success => '分組成功刪除' } }
			else
				format.html { redirect_to importGroup_path(:id => t_id), :flash => { :error => '分組刪除失敗' } }
			end
		end
	end
	
	def upload_file
		@upload = Upload.where(:task_id => params[:t_id], :user_id => current_user.id).first || Upload.new
		@upload.task_id = params[:t_id]
		@upload.user_id = params[:u_id]
		@upload.file = params[:file]
		
		# Rails.logger.debug("--------"+@teams_rate[0]+"--------")
		
		respond_to do |format|
			if( @upload.id == nil && (params[:file] == nil || params[:file] == "") )
				format.html { 
					flash[:error] = '檔案不能為空'
					redirect_to :action => 'show', :id => @upload.task_id
				}
			else
				str = ''
				if @upload.id == nil
					str = '作業上傳成功'
				else
					str = '作業更新成功'
				end
				
				if Time.now < Task.find(params[:t_id]).deadline && @upload.save
					format.html { 
						flash[:success] = str
						redirect_to :action => 'show', :id => @upload.task_id
					}
				else
					format.html { 
						flash[:error] = '作業上傳失敗'
						redirect_to :action => 'show', :id => @upload.task_id
					}
				end
			end
		end
	end
	
	def	edit_file
		@task = Task.find(params[:id])
		@groups = @task.groups.order("inclass_number ASC")
		@upload = Upload.where(:task_id => @task.id, :user_id => current_user.id).first || Upload.new
		@current_group = current_user.groups.where(:task_id => @task.id).first
		
		respond_to do |format|
			if Time.now > @task.deadline
				format.html { 
						flash[:warning] = '已超過繳交期限'
						redirect_to :action => 'show', :id => @upload.task_id
					}
			else
				format.html
			end
		end
	end
	
	# download member_rating excel
	def view_member_rate
		check_is_tutor
		@task = Task.find(params[:id])
		@member_rates = @task.member_rates.order("from_id ASC, to_id ASC")
		
		headers["Content-Disposition"] = "attachment; filename=\"#{@task.title}_teammate_rate.xls\""
		respond_to do |format|
			format.html
			format.xls # { send_data @products.to_csv(col_sep: "\t") }
		end
	end
	
	# download grouping_rating excel
	def view_rate
		check_is_tutor
		@task = Task.find(params[:id])
		@groups = @task.groups.order("inclass_number ASC")
		
		@rates = []
		@groups.each do |g|
			@sub_rates = Rate.where(:rateable_id => g.id, :rateable_type => 'Group').order("rater_id ASC")
			@sub_rates.each do |s|
				@rates << s
			end
		end
		
		headers["Content-Disposition"] = "attachment; filename=\"#{@task.title}_grouping_rate.xls\""
		respond_to do |format|
			format.html
			format.xls # { send_data @products.to_csv(col_sep: "\t") }
		end
	end
	
	# avoid student key this path to view this page
	def check_is_tutor
		redirect_to groups_path, alert: "很抱歉，您沒有權限閱覽該頁面" if current_user.school_class_id > -1
	end
end
