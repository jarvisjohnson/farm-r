# == Schema Information
#
# Table name: stripe_payments
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  payer_id              :string(255)
#  recipient_id          :string(255)
#  organization_id       :string(255)
#  transaction_id        :integer
#  status                :string(255)
#  community_id          :integer
#  sum_cents             :integer
#  currency              :string(255)
#  stripe_transaction_id :string(255)
#  vat_price_cents       :integer
#  discount_total_cents  :integer
#
# Indexes
#
#  index_stripe_payments_on_community_id  (community_id)
#

require 'rails_helper'

RSpec.describe StripePayment, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
