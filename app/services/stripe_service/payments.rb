module StripeService
  module Payments
    CommunityModel = ::Community

    module Command
      module_function

      def capture_charge(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community   = Community.find(community_id)
        payment     = transaction.payment
        raise
        discount    = DiscountCode.find_by(code: transaction.discount)
        stripe_charge_id = payment.stripe_transaction_id
        # hold_amount = transaction.listing.hold_amount_cents rescue 0
        service_fee = payment.total_commission.cents.to_f
        recipient = payment.recipient
        payer = payment.payer

        Stripe.api_key = payment.payment_gateway.stripe_secret_key
        result, error = nil, nil
        begin
          charge = Stripe::Charge.retrieve(stripe_charge_id)
          result = charge.capture
          discount.update_attributes(active: false, used: true)
        rescue Stripe::InvalidRequestError => e
          error = e.message
        rescue Exception => e
          error = e.message
        end

        if result and result.status == "succeeded"
          # if hold_amount > 0
          #   hold_charge_attrs = {
          #     :amount => hold_amount, # amount in cents
          #     :currency => transaction.payment.currency,
          #     :customer => payer.stripe_customer_id,
          #     :description => "Hold amount from #{payer.full_name} for #{transaction.listing.title}",
          #     :application_fee => service_fee.to_i * 100, # amount in cents
          #     :destination => recipient.stripe_account.stripe_user_id,
          #     :capture => false,
          #     :receipt_email => recipient.emails.first.address,
          #     :metadata => {'listing_id' => payment.tx.listing_id, 'seller_id' => recipient.id, 'buyer_id' =>  payer.id}
          #   }
          #   hold_charge = Stripe::Charge.create(hold_charge_attrs)
          #   payment.update_attributes(hold_amount_transaction_id: hold_charge.id)
          # end
          StripeLog.info("=================================================================================")
          StripeLog.info("Submitted authorized payment #{transaction_id} to settlement")
          StripeLog.info("=================================================================================")
        else
          StripeLog.error("=================================================================================")
          StripeLog.error("Could not submit authorized payment #{transaction_id} to settlement (#{error})")
          StripeLog.error("=================================================================================")
        end

        return result, error
      end

      def void_transaction(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
        community = Community.find(community_id)

        stripe_charge_id = transaction.payment.stripe_transaction_id
        discount    = DiscountCode.find_by(code: transaction.discount)

        Stripe.api_key = transaction.payment.payment_gateway.stripe_secret_key
        result, error = nil, nil
        begin
          ch = Stripe::Charge.retrieve(stripe_charge_id)
          result = ch.refunds.create(:reverse_transfer => true)
          discount.update_attributes(active: true, used: false)
        rescue Stripe::InvalidRequestError => e
          error = e.message
        rescue Exception => e
          error = e.message
        end

        if result and result.status == "succeeded"
          StripeLog.info("=================================================================================")
          StripeLog.info("Voided transaction #{transaction_id}")
          StripeLog.info("=================================================================================")
        else
          StripeLog.error("=================================================================================")
          StripeLog.error("Could not void transaction #{transaction_id}. #{error}")
          StripeLog.error("=================================================================================")
        end

        return result, error
      end

      def find_tx(transaction_id, community_id)
        transaction = Transaction.find(transaction_id)
      end

      def transaction(transaction_id)
        Maybe(TransactionModel.where(id: transaction_id, deleted: false).first)
          .map { |m| Entity.transaction(m) }
          .or_else(nil)
      end      

    end

  end
end