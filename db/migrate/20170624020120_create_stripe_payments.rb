class CreateStripePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_payments do |t|

      t.timestamps
    end
    change_table :stripe_payments do |t|
      t.string :payer_id
      t.string :recipient_id
      t.string :organization_id
      t.integer :transaction_id
      t.string :status
      t.belongs_to :community, foreign_key: true
      t.integer :sum_cents
      t.string :currency
      t.string :stripe_transaction_id

    end
  end
end
