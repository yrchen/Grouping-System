class AddClass < ActiveRecord::Migration
  def change
    create_table :classes do |t|
			t.string :name
			t.timestamps
		end
		
		create_table :courses do |t|
			t.string :name
			t.timestamps
		end
  end
end
