class AddVatPriceToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :vat_price_cents, :integer
    # add_column :transactions, :vat_price, :integer
    add_column :stripe_payments, :vat_price_cents, :integer
  end
end
