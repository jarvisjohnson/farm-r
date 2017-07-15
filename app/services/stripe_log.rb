module StripeLog
  class << self
    def info(msg)
      # Currently, we're showing only warn and error levels. However, we want to show Stripe infos
      Rails.logger.warn "[Stripe] #{msg}"
    end

    def warn(msg)
      Rails.logger.warn "[Stripe] #{msg}"
    end

    def error(msg)
      Rails.logger.error "[Stripe] #{msg}"
    end
  end
end
