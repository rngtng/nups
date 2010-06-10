#http://railscasts.com/episodes/206-action-mailer-in-rails-3

ActionMailer::Base.smtp_settings = {
  :address              => "smtp.c-art-web.de",
  :port                 => 587,
  :domain               => "c-art-web.de",
  :user_name            => "",
  :password             => "",
  :authentication       => "",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = "localhost:3000"
Mail.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?