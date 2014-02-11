class AddPublishedSatisfaction < ActiveRecord::Migration
  def change
		add_column :tasks, :publish, :datetime
		add_column :student_group_relationships, :satisfaction, :integer
  end
end
