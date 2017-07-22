class CreateStripeAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :stripe_accounts do |t|

      t.timestamps
    end
    change_table :stripe_accounts do |t|
      t.belongs_to :person
      t.string :publishable_key
      t.string :secret_key
      t.string :stripe_user_id
      t.string :currency
      t.string :stripe_account_type
      t.text :stripe_account_status

    end
  end
end

