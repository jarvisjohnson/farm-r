class AddCurrencyToStripePayments < ActiveRecord::Migration[5.1]
  def change
    change_table :stripe_payments do |t|
      t.integer  "sum_cents"
      t.string   "currency"
      t.string   "stripe_transaction_id"
    end
  end
end
