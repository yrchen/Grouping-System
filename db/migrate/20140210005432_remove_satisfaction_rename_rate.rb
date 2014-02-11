class RemoveSatisfactionRenameRate < ActiveRecord::Migration
  def change
		remove_column :student_group_relationships, :satisfaction
		rename_table :rates, :member_rates
  end
end
