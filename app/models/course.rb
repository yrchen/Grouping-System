# encoding: utf-8
class Course < ActiveRecord::Base
  attr_accessible :name, :tutor_id, :group_mode
	validates_uniqueness_of :name
	validates_presence_of :name
	
	# has_many :groups
	# has_many :school_classes, :through => :groups
	has_many :tasks
	has_many :user_course_relationships
	has_many :users, :through => :user_course_relationships
	
	def self.import(file)
		s = open_spreadsheet(file)
		header = s.row(1)
		name = s.cell(2, 'B')
		
		if(!find_by_name(name))
			course = find_by_name(name) || new
			course.name = name
			
			if( (course.name != "") && (course.name != nil) )
				course.save!
			end
		end
	end
	
	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
			when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
			when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
		end
	end
end
