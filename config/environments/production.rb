require_relative './common.rb'
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests.
  # If live updates for translations are in use, caching is set to false.
  config.cache_classes = (APP_CONFIG.update_translations_on_every_page_load == "true" ? false : true)

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Basic log config, for calls to Rails.logger.<level> { <message> }
  config.logger = ::Logger.new(STDOUT)
  # Formats log entries into: LEVEL MESSAGE
  # Heroku adds to this timestamp and worker/dyno id, so datetime can be stripped
  config.logger.formatter = ->(severity, datetime, progname, msg) { "#{severity} #{msg}\n" }

  # Lograge config, overrides default instrumentation for logging ActionController and ActionView logging
  config.lograge.enabled = true
  config.lograge.custom_options = ->(event) {
    params = event.payload[:params].except('controller', 'action')

    { params: params,
      host: event.payload[:host],
      community_id: event.payload[:community_id],
      current_user_id: event.payload[:current_user_id],
      user_agent: event.payload[:user_agent],
      referer: event.payload[:referer],
      forwarded_for: event.payload[:forwarded_for],
      request_uuid: event.payload[:request_uuid] }
  }

  # to ignore certain messages, see commit e1ac643f677b0a9f73b10454fa04f67595c8c0c5

  config.lograge.formatter = Lograge::Formatters::Json.new

  config.after_initialize do
    ActiveRecord::Base.logger = Rails.logger.clone
    ActiveRecord::Base.logger.level = Logger::INFO
    ActionMailer::Base.logger = Rails.logger.clone
    ActionMailer::Base.logger.level = Logger::INFO
  end

  # Prefer redis instead of memcached
  config.cache_store =
    if ENV["redis_host"].present?
      Readthis.fault_tolerant = true
      [:readthis_store, {
         redis: { host: ENV["redis_host"],
                  port: ENV["redis_port"],
                  driver: :hiredis},
         db: ENV["redis_db"],
         namespace: "cache",
         expires_in: ENV["redis_expires_in"] || 240 # default, 4 hours in minutes
       }]
    else
      [:dalli_store, (ENV["MEMCACHIER_GREEN_SERVERS"] || "").split(","), {
         username: ENV["MEMCACHIER_GREEN_USERNAME"],
         password: ENV["MEMCACHIER_GREEN_PASSWORD"],
         failover:  true,
         socket_timeout: 1.5,
         socket_failure_delay:  0.2,
         namespace: ENV["MEMCACHED_NAMESPACE"] || "sharetribe-production",
         compress: true
       }]
    end

  # Compress JavaScript and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  config.action_mailer.perform_caching = false

  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.raise_delivery_errors = true

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  # config.i18n.fallbacks = true #fallbacks defined in intitializers/i18n.rb


  mail_delivery_method = (APP_CONFIG.mail_delivery_method.present? ? APP_CONFIG.mail_delivery_method.to_sym : :sendmail)

  config.action_mailer.delivery_method = mail_delivery_method

  # Images in emails
  config.action_mailer.asset_host = APP_CONFIG.email_asset_host

  if mail_delivery_method == :smtp
    ActionMailer::Base.smtp_settings = {
      :address              => APP_CONFIG.smtp_email_address,
      :port                 => APP_CONFIG.smtp_email_port,
      :domain               => APP_CONFIG.smtp_email_domain,
      :user_name            => APP_CONFIG.smtp_email_user_name,
      :password             => APP_CONFIG.smtp_email_password,
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
  end

  # Sendmail is used for some mails (e.g. Newsletter) so configure it even when smtp is the main method
  ActionMailer::Base.sendmail_settings = {
    :location       => '/usr/sbin/sendmail',
    :arguments      => '-i -t'
  }

  ActionMailer::Base.perform_deliveries = true # the "deliver_*" methods are available

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :log

  # We don't need schema dumps in this environment
  config.active_record.dump_schema_after_migration = false
end
