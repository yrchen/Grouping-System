class CreateUploadTable < ActiveRecord::Migration
  def change
		create_table :uploads do |t|
			t.integer :user_id
			t.integer :task_id
			t.string :file
			
			t.timestamps
		end
  end
end
