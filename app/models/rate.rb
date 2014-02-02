class Rate < ActiveRecord::Base
	attr_accessible :task_id, :from_id, :to_id, :rate
	validates_presence_of :task_id, :from_id, :to_id, :rate
	
	belongs_to :task
end
