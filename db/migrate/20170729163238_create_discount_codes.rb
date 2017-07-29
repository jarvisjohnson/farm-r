class CreateDiscountCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :discount_codes do |t|
      t.string :code, unique: true
      t.boolean :used, default: false
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
