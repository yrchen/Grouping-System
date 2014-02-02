class FixToCollegeStudent < ActiveRecord::Migration
  def change
		add_column :courses, :user_id, :integer
		add_column :courses, :group_mode, :integer
		
		drop_table :groups
		create_table :groups do |t|
			t.integer :task_id
			t.integer :inclass_number
			
			t.timestamps
		end
		
		add_column :users, :name, :string
		
		create_table :tasks do |t|
			t.string :title
			t.integer :category
			t.integer :course_id
			t.datetime :deadline
			
			t.timestamps
		end
		
		create_table :student_group_relationships do |t|
			t.integer :user_id
			t.integer :group_id
			
			t.timestamps
		end
		
		create_table :scores do |t|
			t.integer :task_id
			t.integer :user_id
			t.integer :score
			
			t.timestamps
		end
  end
end
