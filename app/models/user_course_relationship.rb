class UserCourseRelationship < ActiveRecord::Base
	attr_accessible :course_id, :user_id
	validates_presence_of :course_id, :user_id

  belongs_to :course
	belongs_to :user
	
	def self.import(file)
		s = open_spreadsheet(file)
		header = s.row(1)
		c_name = s.cell(2, 'A')
		c_id = SchoolClass.find_by_name(c_name).id
		
		(2..s.last_row).each do |i|
			# store excel each row
			row = Hash[[header, s.row(i)].transpose]
			
			user_id = User.find_by_account(s.cell(i, 'C')).id
			course_id = Course.find_by_name(s.cell(i, 'B')).id
			has_relationship = where( :course_id => course_id, :user_id => user_id).first
			
			if( !has_relationship )
				rel = new
				rel.course_id = course_id
				rel.user_id = user_id
				
				rel.save!
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
