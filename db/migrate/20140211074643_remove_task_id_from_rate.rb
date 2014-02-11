class RemoveTaskIdFromRate < ActiveRecord::Migration
  def change
		remove_column :rates, :task_id
  end
end
