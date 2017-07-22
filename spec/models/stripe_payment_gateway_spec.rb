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
#  gbp_vat                :integer          default(20)
#  eur_vat                :integer          default(23)
#
# Indexes
#
#  index_stripe_payment_gateways_on_community_id  (community_id)
#

require 'rails_helper'

RSpec.describe StripePaymentGateway, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
