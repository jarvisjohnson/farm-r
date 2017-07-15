class CreateStripePaymentGateways < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_payment_gateways do |t|

      t.timestamps
    end
    change_table :stripe_payment_gateways do |t|
      t.belongs_to :community, foreign_key: true
      t.string :stripe_publishable_key
      t.string :stripe_secret_key
      t.string :stripe_client_id
      t.integer :commission_from_seller

    end
  end
end
