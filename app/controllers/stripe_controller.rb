class StripeController < ApplicationController

  def update_payment_info
    Stripe.api_key = @current_community.payment_gateway.stripe_secret_key
    stripe_manager = @current_user.stripe_account.stripe_manager
    document = File.new(params[:identiy_file].path) rescue nil
    stripe_manager.update_account!(params: params, document: document)
    redirect_to stripe_account_settings_payment_path( @current_user )
  end

  # Confirm a connection to a Stripe account.
  # Only works on the currently logged in user.
  # See app/services/stripe_connect.rb for #verify! details.
  def confirm
    connector = StripeOauth.new( @current_user, @current_community )
    if params[:code]
      # If we got a 'code' parameter. Then the
      # connection was completed by the user.
      connector.verify!( params[:code] )

    elsif params[:error]
      # If we have an 'error' parameter, it's because the
      # user denied the connection request. Other errors
      # are handled at #oauth_url generation time.
      flash[:error] = "Authorization request denied."
    end
    redirect_to stripe_account_settings_payment_path( @current_user )
  end

  # Deauthorize the application from accessing
  # the connected Stripe account.
  # Only works on the currently logged in user.
  def deauthorize
    connector = StripeOauth.new( @current_user, @current_community )
    connector.deauthorize!
    flash[:notice] = "Account disconnected from Stripe."
    redirect_to stripe_account_settings_payment_path( @current_user )
  end

end
