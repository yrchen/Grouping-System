class ChangeUserClassIdType < ActiveRecord::Migration
  def change
		change_column(:users, :class_id, :integer) 
  end
end
