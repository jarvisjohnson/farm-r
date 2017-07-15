class AddCommissionFromSellerToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :commission_from_seller, :integer
  end
end
