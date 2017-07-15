module StripeHelper

  TxApi = TransactionService::API::Api

  module_function

  # Check that both the community is fully configured with an active
  # :paypal payment gateway and that the given user has connected his
  # paypal account.
  def user_and_community_ready_for_payments?(person_id, community_id)
    community = Community.find(community_id)
    person = Person.find(person_id)

    community.stripe_in_use? && person.stripe_connected_and_tranfers_enabled?
  end

  # Check that the currently active payment gateway (there can be only
  # one active at any time) for the community is :paypal. This doesn't
  # check that the gateway is fully configured. Use
  # community_ready_for_payments? if that's what you need.
  def stripe_active?(community_id)
    Community.find(community_id).stripe_in_use?
  end


  # Check if the user has open listings in the community but has not
  # finished connecting his stripe account.
  def open_listings_with_missing_payment_info?(user_id, community_id)
    stripe_active?(community_id) &&
    !user_and_community_ready_for_payments?(user_id, community_id) &&
    open_listings_with_payment_process?(community_id, user_id)
  end

  def open_listings_with_payment_process?(community_id, user_id)
    processes = TransactionService::API::Api.processes.get(community_id: community_id)[:data]
    payment_process_ids = processes.reject { |p| p[:process] == :none }.map { |p| p[:id] }

    if payment_process_ids.empty?
      false
    else
      listing_count = Listing
                      .where(
                        community_id: community_id,
                        author_id: user_id,
                        open: true,
                        transaction_process_id: payment_process_ids)
                      .count

      listing_count > 0
    end
  end

end