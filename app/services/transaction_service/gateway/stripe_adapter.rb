module TransactionService::Gateway
  class StripeAdapter < GatewayAdapter

    PaymentModel = ::StripePayment

    def create_payment(tx:, gateway_fields:, force_sync: nil)
      payment_gateway_id = StripePaymentGateway.where(community_id: tx[:community_id]).pluck(:id).first
      # raise
      shipping_price = tx[:shipping_price] || Money.new(0, tx[:unit_price].currency)
      
      payment = StripePayment.create({
        transaction_id: tx[:id],
        community_id: tx[:community_id],
        status: :pending,
        payer_id: tx[:starter_id],
        recipient_id: tx[:listing_author_id],
        currency: tx[:unit_price].currency,
        sum_cents: ((tx[:unit_price] * tx[:listing_quantity]) + shipping_price).cents
      })

      result, error = StripeSaleService.new(payment, gateway_fields).pay(false)
      
      if result.present? && !(result.is_a? String) && result.status == "succeeded"
        SyncCompletion.new(Result::Success.new({result: true}))
      else
        TransactionService::Process::Transition.transition_to(tx[:id], :errored)
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def reject_payment(tx:, reason: nil)
      result, error = StripeService::Payments::Command.void_transaction(tx[:id], tx[:community_id])
      if result and result.status == "succeeded"
        SyncCompletion.new(Result::Success.new({result: true}))
      else
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def complete_preauthorization(tx:)
      result, error = StripeService::Payments::Command.capture_charge(tx[:id], tx[:community_id])
      if result and result.status == "succeeded"
        transaction = Transaction.find(tx[:id])
        seller = Person.find(tx[:listing_author_id])

        update_seller_transaction_description(transaction, seller) 
        SyncCompletion.new(Result::Success.new({result: true}))
       
      else
        SyncCompletion.new(Result::Error.new(error))
      end
    end

    def get_payment_details(tx:)
      # raise
      shipping_price = tx[:shipping_price] || Money.new(0, tx[:unit_price].currency)
      total_price = (tx[:unit_price]) * tx[:listing_quantity] + shipping_price
      { payment_total: total_price,
        total_price: total_price,
        charged_commission: nil,
        payment_gateway_fee: nil }
    end

    def update_seller_transaction_description(transaction, seller)
      charge_id = transaction.payment.stripe_transaction_id
      seller_stripe_id = seller.stripe_account.stripe_user_id
      # Get the details we need
      charge = Stripe::Charge.retrieve({ 
        :id => charge_id, 
        :expand => ['transfer.destination_payment']
      })
      # Get the destination_payment id
      destination_payment_id = charge.transfer.destination_payment.id
      # Retrieve the payment  
      destination_payment = Stripe::Charge.retrieve({ :id => destination_payment_id }, { :stripe_account => seller_stripe_id})
      # Set the description
      buyer = Person.find(transaction.starter_id)
      destination_payment.description = "Closet Raid transaction from user: '#{buyer.username}' for '#{transaction.listing_title}'."
      destination_payment.save
    end    

  end
end