class AddChargeVatToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :charge_vat, :boolean, default: false
    add_column :listings, :charge_vat, :boolean, default: false
  end
end
