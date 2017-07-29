class AddVatToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :vat, :integer, default: 20
  end
end
