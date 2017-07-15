# == Schema Information
#
# Table name: stripe_payment_gateways
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  community_id           :string(22)
#  stripe_publishable_key :string(255)
#  stripe_secret_key      :string(255)
#  stripe_client_id       :string(255)
#  commission_from_seller :integer
#
# Indexes
#
#  index_stripe_payment_gateways_on_community_id  (community_id)
#

class StripePaymentGateway < ApplicationRecord
  belongs_to :community
  
  def name
    "stripe"
  end

  def configured?
    [
      stripe_publishable_key,
      stripe_secret_key,
      stripe_client_id
    ].all? { |x| x.present? }
  end

  def tranfers_enabled?
    configured?
  end

  def gateway_type
    :stripe
  end

end
