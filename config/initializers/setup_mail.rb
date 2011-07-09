#http://railscasts.com/episodes/206-action-mailer-in-rails-3
#http://blog.thembid.com/2007/07/31/sending-smtp-e-mails-with-ruby-on-rails/
#http://apidock.com/rails/ActionMailer/Base
#http://blog.scopeport.org/ruby-on-rails/rails-smtp-configuration-parameters-database/

if Rails.env.production?
  rails_root = Rails.root.to_s || File.dirname(__FILE__) + '/../..'

  mail_config = YAML.load_file(rails_root + '/config/mail.yml')

  ActionMailer::Base.delivery_method = mail_config['method'].to_sym
  ActionMailer::Base.smtp_settings   = mail_config['smtp_settings']
end
