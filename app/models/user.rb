# encoding: utf-8
class User < ActiveRecord::Base
	has_secure_password
  attr_accessible :account, :school_class_id, :password, :password_confirmation, :name
	validates_uniqueness_of :account
	validates_presence_of :account, :school_class_id
	
	belongs_to :school_class
	has_many :student_group_relationships
	has_many :groups, :through => :student_group_relationships
	has_many :scores, :through => :tasks
	has_many :user_course_relationships
	has_many :courses, :through => :user_course_relationships
	has_many :uploads
	
	ajaxful_rater
	
	def self.import(file)
		s = open_spreadsheet(file)
		
		# header is every attribute's name
		header = s.row(1)
		c_name = s.cell(2, 'A')
		c_id = SchoolClass.find_by_name(c_name).id
		
		# To find that have we store those students before (They will store in array: 'students')
		students = User.select("account, school_class_id").where( :school_class_id => c_id )
		
		(2..s.last_row).each do |i|
			# store excel each row
			row = Hash[[header, s.row(i)].transpose]
			
			# if we have this students data, don't save again
			if( !students.find_by_account(row["學號"]) )
				# create new student
				stu = new
				stu.account = row["學號"]
				stu.name = row["姓名"]
				stu.password = "1111"
				stu.school_class_id = c_id
				
				if( (stu.account != "") && (stu.account != nil) )
					stu.save!
				end
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
