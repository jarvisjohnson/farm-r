#
# Do Stripe payment
#
class StripeSaleService
  def initialize(payment, payment_params, discount)
    raise
    @discount = DiscountCode.find_by(code: discount)
    # See if the discount is active and hasn't been used
    use_discount = !@discount.nil? && @discount.active? && !@discount.used?
    @payment = payment
    @community = payment.community
    @payer = payment.payer
    @currency = @payer.currency
    @recipient = payment.recipient
    # If discount works, remove the commission from the total
    @amount = use_discount ? payment.sum_cents.to_f - payment.total_commission.cents.to_f : payment.sum_cents.to_f
    # If discount works, don't charge the commission
    @service_fee = use_discount ? 0 : payment.total_commission.cents.to_f
    @params = payment_params || {}
  end

  def pay(capture)
    response, error = call_stripe_api(capture)
    if response.present?
      save_transaction_id!(response)
      change_payment_status_to_paid!
    end

    log_result(response, error)

    return response, error
  end

  private

  def call_stripe_api(capture)
    with_expection_logging do
      StripeLog.warn("Sending sale transaction from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}")
      charge, error = nil, nil
      token = @params[:stripeToken]
      # Get the credit card details submitted by the form
      charge_attrs = {
        :amount => @amount.to_i, # amount in cents
        :currency => @currency,
        :source => token,
        :description => "Listing fee charge to #{@recipient.full_name} from #{@payer.full_name}",
        :application_fee => @service_fee.to_i, # amount in cents
        :destination => @recipient.stripe_account.stripe_user_id,
        :capture => capture,
        :receipt_email => @recipient.emails.first.address,
        :metadata => {'listing_id' => @payment.tx.listing_id, 'seller_id' => @recipient.id, 'buyer_id' =>  @payer.id}
      }

      begin

        Stripe.api_key = @community.payment_gateway.stripe_secret_key

        # Create the charge on Stripe's servers - this will charge the user's card
        charge = Stripe::Charge.create(charge_attrs)
      rescue Stripe::CardError => e
        error = e.json_body[:error][:message]
      rescue Exception => e
        error = e.message
      end

      return charge, error
    end
  end

  def save_transaction_id!(response)
    @payment.update_attributes(stripe_transaction_id: response.id)
  end

  def change_payment_status_to_paid!
    @payment.paid!
  end

  def log_result(response, error)
    if response.present?
      transaction_id = response.id
      StripeLog.warn("Successful sale transaction #{transaction_id} from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}")
    else
      StripeLog.error("Unsuccessful sale transaction from #{@payer.id} to #{@recipient.id}. Amount: #{@amount}, fee: #{@service_fee}: #{error}")
    end
  end

  def with_expection_logging(&block)
    begin
      block.call
    rescue Exception => e
      StripeLog.error("Expection #{e}")
      raise e
    end
  end
end