# == Schema Information
#
# Table name: stripe_accounts
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_id             :string(22)
#  publishable_key       :string(255)
#  secret_key            :string(255)
#  stripe_user_id        :string(255)
#  currency              :string(255)
#  stripe_account_type   :string(255)
#  stripe_account_status :text(65535)
#
# Indexes
#
#  index_stripe_accounts_on_person_id  (person_id)
#

class StripeAccount < ApplicationRecord
  serialize :stripe_account_status, JSON

  belongs_to :person

  # Stripe account type checks
  def oauth?; stripe_account_type == 'oauth'; end

  def stripe_manager
    case stripe_account_type
    when 'oauth' then StripeOauth.new(self)
    end
  end

  def tranfers_enabled?
    true
  end
end
