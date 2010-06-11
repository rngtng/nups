class NewsletterMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def issue(newsletter, recipient)

    @newsletter = newsletter
    @recipient  = recipient
    
    #default_url_options[:host]    = _('cmd_url_host')
    
    mail :to => user.email, :subject => newsletter.subject, :from => newsletter.from
  end
end
