class AddDiscountTotalToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :discount_total_cents, :integer
  end
end
