class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :account
      t.string :password_digest
      t.string :class_id

      t.timestamps
    end
  end
end
