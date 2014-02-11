class ChangeRateDefaultValue < ActiveRecord::Migration
  def change
		change_column :rates, :stars, :integer, :default => 0
  end
end
