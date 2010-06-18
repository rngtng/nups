class NewsletterMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def issue(newsletter, recipient)
    default_url_options[:host] = newsletter.host
    
    content_html = content_text = newsletter.content #_html(recipient)
    #l = render_to_string template_html
    #newsletter.content_text(recipient)
    
    mail :to => recipient.email, :subject => newsletter.subject, :from => newsletter.from do |format|
        format.html { render :text => content_html }
        format.text { render :text => content_text }
      end
  end
end
