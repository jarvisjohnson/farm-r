module TransactionService::Gateway
  class StripeSettingsAdapter < SettingsAdapter

    PaymentSettingsStore = TransactionService::Store::PaymentSettings

    def configured?(community_id:, author_id:)
      payment_settings = Maybe(PaymentSettingsStore.get_active(community_id: community_id)).select {|set| stripe_settings_configured?(set)}

      personal_account_verified = stripe_account_verified?(person_id: author_id, settings: payment_settings)
      community_account_verified = community_account_verified?(community_id: community_id)

      payment_settings_available = payment_settings.map {|_| true }.or_else(false) #TODO UNVERIFIED

      [personal_account_verified, community_account_verified, payment_settings_available].all?
    end

    def tx_process_settings(opts_tx)
      currency = opts_tx[:unit_price].currency
      p_set = PaymentSettingsStore.get_active(community_id: opts_tx[:community_id])

      {minimum_commission: Money.new(p_set[:minimum_transaction_fee_cents], currency),
       commission_from_seller: p_set[:commission_from_seller],
       automatic_confirmation_after_days: p_set[:confirmation_after_days]}
    end

    private

    def stripe_settings_configured?(settings)
      settings[:payment_gateway] == :stripe && !!settings[:commission_from_seller] && !!settings[:minimum_price_cents]
    end

    def stripe_account_verified?(person_id:, settings: Maybe(nil))
      person = Person.find(person_id)
      person.stripe_connected_and_tranfers_enabled?
    end

    def community_account_verified?(community_id:)
      community = Community.find(community_id)
      community.stripe_transfers_enabled?
    end

  end
end