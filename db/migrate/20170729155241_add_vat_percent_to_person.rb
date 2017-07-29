class AddVatPercentToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :vat, :integer, default: 20
  end
end
