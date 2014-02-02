# encoding: utf-8
class StudentGroupRelationship < ActiveRecord::Base
  attr_accessible :user_id, :group_id
	validates_presence_of :user_id, :group_id
	
	belongs_to :user
	belongs_to :group
	
	def self.import(t_id, file)
		s = open_spreadsheet(file)
		header = s.row(1)
		
		(2..s.last_row).each do |i|
			# store excel each row
			row = Hash[[header, s.row(i)].transpose]
			
			group = Group.where(:task_id => t_id, :inclass_number => row['分組編號']).first
			user = User.find_by_account(row['學號'])
			if( group && user && !where(:user_id => user.id, :group_id => group.id).first )
				sg_relationship = new
				sg_relationship.user_id = user.id
				sg_relationship.group_id = group.id
				
				if( sg_relationship.user_id != nil && sg_relationship.group_id != nil)
					sg_relationship.save!
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
