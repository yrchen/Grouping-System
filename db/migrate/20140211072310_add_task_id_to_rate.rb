class AddTaskIdToRate < ActiveRecord::Migration
  def change
		add_column :rates, :task_id, :integer
  end
end
