class MemberRate < ActiveRecord::Base
	attr_accessible :task_id, :from_id, :to_id, :rate
	validates_presence_of :task_id, :from_id, :to_id
	
	belongs_to :task
	
	ajaxful_rateable :stars => 5
end
