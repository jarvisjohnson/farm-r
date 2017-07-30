class AddDiscountToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :discount, :string
  end
end
