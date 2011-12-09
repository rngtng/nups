#http://railscasts.com/episodes/206-action-mailer-in-rails-3
#http://blog.thembid.com/2007/07/31/sending-smtp-e-mails-with-ruby-on-rails/
#http://apidock.com/rails/ActionMailer/Base
#http://blog.scopeport.org/ruby-on-rails/rails-smtp-configuration-parameters-database/

$mail_config = if Rails.env.production?
  YAML.load_file (Rails.root + 'config/mail.yml').to_s
else
  cfg = Nups::Application.config.action_mailer
  {
    "method"        => cfg.delivery_method,
    "host"          => cfg.default_url_options[:host],
    "smtp_settings" => cfg.smtp_settings
  }
end

