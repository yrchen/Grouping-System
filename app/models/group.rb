# encoding: utf-8
class Group < ActiveRecord::Base
  attr_accessible :course_id, :school_class_id, :mode
	validates_presence_of :course_id, :school_class_id
	
	belongs_to :school_class
	belongs_to :course
	
	def self.import(file)
		s = open_spreadsheet(file)
		header = s.row(1)
		class_id = SchoolClass.find_by_name(s.cell(2, 'A')).id
		course_id = Course.find_by_name(s.cell(2, 'B')).id
		has_group = where( :course_id => course_id, :school_class_id => class_id).first
		
		if(!has_group)
			group = new
			group.course_id = course_id
			group.school_class_id = class_id
			
			group.save!
		end
	end
	
	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
			when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
			when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
		end
	end
end
