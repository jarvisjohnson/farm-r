class AddCurrencyToPerson < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :currency, :string, default: "GBP"
  end
end
