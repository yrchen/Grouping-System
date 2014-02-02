class Score < ActiveRecord::Base
  attr_accessible :task_id, :user_id, :score
	validates_presence_of :task_id, :user_id
	
	belongs_to :task
	belongs_to :user
end
