class CombineScoreUpload < ActiveRecord::Migration
  def change
		drop_table :scores
		add_column :uploads, :score, :integer
		create_table :rates do |t|
			t.integer :task_id
			t.integer :from_id
			t.integer :to_id
			t.integer :rate
			
			t.timestamps
		end
  end
end
