#http://railscasts.com/episodes/206-action-mailer-in-rails-3
#http://blog.thembid.com/2007/07/31/sending-smtp-e-mails-with-ruby-on-rails/
#http://apidock.com/rails/ActionMailer/Base

if Rails.env.production?
  mailconfig = YAML::load_file(File.join(File.dirname(__FILE__), 'mail.yml'))
  
  ActionMailer::Base.delivery_method = mailconfig['method'].to_sym
  ActionMailer::Base.default_url_options[:host] = mailconfig['host']
  
  ActionMailer::Base.server_settings = mailconfig['smtp_options']
  
elsif Rails.env.development?
  ActionMailer::Base.default_url_options[:host] = "localhost:3000"
  
  Mail.register_interceptor(DevelopmentMailInterceptor)
end