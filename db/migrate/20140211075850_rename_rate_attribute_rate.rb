class RenameRateAttributeRate < ActiveRecord::Migration
  def change
		rename_column :member_rates, :rate, :rate_id
  end
end
