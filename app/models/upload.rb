# encoding: utf-8
class Upload < ActiveRecord::Base
  attr_accessible :user_id, :task_id, :file, :score
	mount_uploader :file, FileUploader
	
	belongs_to :task
	belongs_to :user
	
	def self.import(t_id, file)
		s = open_spreadsheet(file)
		header = s.row(1)
		
		(2..s.last_row).each do |i|
			# store excel each row
			row = Hash[[header, s.row(i)].transpose]
			
			if upload = User.find_by_account(row['學號']).uploads.find_by_task_id(t_id)
				upload.score = row['成績']
				
				if upload.score != nil
					upload.save!
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
