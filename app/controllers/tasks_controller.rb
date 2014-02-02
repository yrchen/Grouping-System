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
				format.html { redirect_to chooseCourse_path, notice: '各個欄位皆不能留白' }
			else
				if @task.save
					format.html { redirect_to chooseCourse_path, notice: '文章發表成功' }
				else
					format.html { redirect_to chooseCourse_path, notice: '文章發表失敗' }
				end
			end
		end
	end
	
	def index
		@tasks = Task.where(:course_id => params[:c_id]).order("created_at DESC")
	end
	
	def show
		@task = Task.find(params[:id])
		@groups = @task.groups
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
			if @current_group != nil
				@team = StudentGroupRelationship.where(:group_id => @current_group.id)
				@team.each do |t|
					@teammates << t.user
				end
			end
			
			# excluse this current user
			@teammates_form = Array.new(@teammates.size){Hash.new}
			@teammates.each_with_index do |t, idx|
				@teammates_form[idx]['id'] = t.id
				@teammates_form[idx]['name'] = t.name
				@teammates_form[idx]['t_id'] = @task.id
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
				format.html { redirect_to chooseCourse_path, notice: '各個欄位皆不能留白' }
			else
				if @task.update_attributes(params[:task])
					format.html { redirect_to chooseCourse_path, notice: '文章編輯成功' }
				else
					format.html { redirect_to chooseCourse_path, notice: '文章編輯失敗' }
				end
			end
		end
	end
	
	def destroy
		check_is_tutor
		@task = Task.find(params[:id])
		
		respond_to do |format|
			if @task.destroy
				format.html { redirect_to chooseCourse_path, notice: '公告成功刪除' }
			else
				format.html { redirect_to chooseCourse_path, notice: '公告刪除失敗' }
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
		
		redirect_to root_url, notice: "資料已儲存"
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
		
		redirect_to root_url, notice: "資料已儲存"
	end
	# -------------------------------------------
	
	def view_group
		@task = Task.find(params[:id])
		@groups = @task.groups
		
		if @groups.size == 0
			redirect_to searchGroup_path, notice: "此公告並無分組"
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
				format.html { redirect_to importGroup_path(:id => t_id), notice: '分組成功刪除' }
			else
				format.html { redirect_to importGroup_path(:id => t_id), notice: '分組刪除失敗' }
			end
		end
	end
	
	def upload_file
		@upload = Upload.where(:task_id => params[:t_id], :user_id => current_user.id).first || Upload.new
		@upload.task_id = params[:t_id]
		@upload.user_id = params[:u_id]
		@upload.file = params[:file]
		
		if params[:has_group].to_i != 0
			# very bad code...but I have no time
			@teams = Array.new(4){Hash.new}
			@teams[0]['rate'] = params[:rate_0]
			@teams[1]['rate'] = params[:rate_1]
			@teams[2]['rate'] = params[:rate_2]
			@teams[3]['rate'] = params[:rate_3]
			
			@teams[0]['id'] = params[:team_id_0]
			@teams[1]['id'] = params[:team_id_1]
			@teams[2]['id'] = params[:team_id_2]
			@teams[3]['id'] = params[:team_id_3]
		end
		
		# Rails.logger.debug("--------"+@teams_rate[0]+"--------")
		
		respond_to do |format|
			if( params[:has_group].to_i != 0 && (params[:rate_0] == "" || params[:rate_1] == "" || params[:rate_2] == "" || params[:rate_3] == "") )
				format.html { 
					flash[:notice] = '作業繳交失敗...沒給隊友評價喔!'
					redirect_to :action => 'show', :id => @upload.task_id
				}
			elsif( @upload.id == nil && (params[:file] == nil || params[:file] == "") )
				format.html { 
					flash[:notice] = '檔案不能為空'
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
					# save for teammates rate
					if params[:has_group].to_i != 0
						@teams.each_with_index do |t, idx|
							if current_user.id != t['id'].to_i
								@rate = Rate.where(:task_id => params[:t_id], :from_id => current_user.id, :to_id => t['id'].to_i).first || Rate.new(:task_id => params[:t_id], :from_id => current_user.id, :to_id => t['id'].to_i, :rate => t['rate'].to_i)
								@rate.rate = t['rate'].to_i
								
								if @rate.to_id != 0
									@rate.save
								end
							end
						end
					end
					
					format.html { 
						flash[:notice] = str
						redirect_to :action => 'show', :id => @upload.task_id
					}
				else
					format.html { 
						flash[:notice] = '作業上傳失敗'
						redirect_to :action => 'show', :id => @upload.task_id
					}
				end
			end
		end
	end
	
	def	edit_file
		@task = Task.find(params[:id])
		@groups = @task.groups
		@upload = Upload.where(:task_id => @task.id, :user_id => current_user.id).first || Upload.new
		
		respond_to do |format|
			if Time.now > @task.deadline
				format.html { 
						flash[:notice] = '已超過繳交期限'
						redirect_to :action => 'show', :id => @upload.task_id
					}
			else
				format.html
			end
		end
	end
	
	# avoid student key this path to view this page
	def check_is_tutor
		redirect_to groups_path, alert: "很抱歉，您沒有權限閱覽該頁面" if current_user.school_class_id > -1
	end
end
