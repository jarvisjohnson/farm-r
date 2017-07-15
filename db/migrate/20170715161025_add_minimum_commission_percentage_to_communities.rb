class AddMinimumCommissionPercentageToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :minimum_transaction_fee_cents, :integer, after: :commission_from_seller
  end
end
