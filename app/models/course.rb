# encoding: utf-8
class Course < ActiveRecord::Base
  attr_accessible :name
	validates_uniqueness_of :name
	
	def self.import(file)
		s = open_spreadsheet(file)
		header = s.row(1)
		name = s.cell(2, 'B')
		
		if(!find_by_name(name))
			course = find_by_name(name) || new
			course.name = name
			course.save!
		end
	end
	
	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
			when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
			when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
		end
	end
end
