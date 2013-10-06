class RenameUserSchoolClassId < ActiveRecord::Migration
  def change
		rename_column( :users, :class_id, :school_class_id)
  end
end
