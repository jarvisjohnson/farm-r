class CreateStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_accounts do |t|
      t.belongs_to :person, foreign_key: true
      t.string :publishable_key
      t.string :secret_key
      t.string :stripe_user_id
      t.string :currency
      t.string :stripe_account_type
      t.text :stripe_account_status

      t.timestamps
    end
  end
end

