# encoding: utf-8
class User < ActiveRecord::Base
	has_secure_password
  attr_accessible :account, :class_id, :password, :password_confirmation
	validates_uniqueness_of :account
	
	def self.import(file)
		s = open_spreadsheet(file)
		
		# header is every attribute's name
		header = s.row(1)
		c_name = s.cell(2, 'A')
		c_id = SchoolClass.find_by_name(c_name).id
		
		# To find that have we store those students before (They will store in array: 'students')
		students = User.select("account, class_id").where( :class_id => c_id )
		
		(2..s.last_row).each do |i|
			# store excel each row
			row = Hash[[header, s.row(i)].transpose]
			
			# if we have this students data, don't save again
			if( !students.find_by_account(row["學號"]) )
				# create new student
				stu = new
				stu.account = row["學號"]
				stu.password = "1111"
				stu.class_id = c_id
				stu.save!
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
