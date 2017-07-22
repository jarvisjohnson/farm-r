class AddVatToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :gbp_vat, :integer, default: 20
    add_column :communities, :eur_vat, :integer, default: 23
    add_column :stripe_payment_gateways, :gbp_vat, :integer, default: 20
    add_column :stripe_payment_gateways, :eur_vat, :integer, default: 23
  end
end
