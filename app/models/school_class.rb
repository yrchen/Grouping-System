# encoding: utf-8
class SchoolClass < ActiveRecord::Base
  attr_accessible :name
	validates_uniqueness_of :name
	validates_presence_of :name
	
	has_many :users
	# has_many :groups
	# has_many :courses, :through => :groups
	
	def self.import(file)
		s = open_spreadsheet(file)
		header = s.row(1)
		name = s.cell(2, 'A')
		
		if(!find_by_name(name))
			# Rails.logger.debug("--------In model school class if--------")
			school_class = find_by_name(name) || new
			school_class.name = name
			
			if( (school_class.name != "") && (school_class.name != nil) )
				school_class.save!
			end
		end
	end
	
	def self.open_spreadsheet(file)
		case File.extname(file.original_filename)
			when '.xls' then Roo::Excel.new(file.path, nil, :ignore)
			when '.xlsx' then Roo::Excelx.new(file.path, nil, :ignore)
			else raise "不知名檔案類型: #{file.original_filename}"
		end
	end

end
