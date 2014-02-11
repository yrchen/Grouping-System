class SetDefaultRate < ActiveRecord::Migration
  def change
		change_column :rates, :stars, :integer, :default => 3
  end
end
