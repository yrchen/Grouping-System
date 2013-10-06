class AddGroupTable < ActiveRecord::Migration
  def change
		create_table :groups do |t|
      t.integer :course_id
      t.integer :class_id
      t.integer :mode

      t.timestamps
    end
  end
end
