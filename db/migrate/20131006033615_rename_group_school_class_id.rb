class RenameGroupSchoolClassId < ActiveRecord::Migration
  def change
		rename_column( :groups, :class_id, :school_class_id)
  end
end
