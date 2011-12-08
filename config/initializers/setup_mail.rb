#http://railscasts.com/episodes/206-action-mailer-in-rails-3
#http://blog.thembid.com/2007/07/31/sending-smtp-e-mails-with-ruby-on-rails/
#http://apidock.com/rails/ActionMailer/Base
#http://blog.scopeport.org/ruby-on-rails/rails-smtp-configuration-parameters-database/

if Rails.env.production?
  $mail_config = YAML.load_file (Rails.root + 'config/mail.yml').to_s

  ActionMailer::Base.delivery_method = $mail_config['method'].to_sym
  ActionMailer::Base.smtp_settings   = $mail_config['smtp_settings']
else
  $mail_config = {}
end

