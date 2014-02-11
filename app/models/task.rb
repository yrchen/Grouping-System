# encoding: utf-8
class Task < ActiveRecord::Base
	attr_accessible :course_id, :title, :category, :deadline, :publish
	validates_presence_of :course_id, :title, :category, :deadline
	
	belongs_to :course
	has_many :groups
	has_many :scores
	has_many :member_rates
	has_many :uploads
end
