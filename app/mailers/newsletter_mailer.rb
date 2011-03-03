class NewsletterMailer < ActionMailer::Base

  def issue(sending, recipient)
    newsletter = sending.newsletter

    if mail_config = newsletter.account.mail_config
      NewsletterMailer.delivery_method            = mail_config['method'].to_sym
      NewsletterMailer.default_url_options[:host] = mail_config['host']
      NewsletterMailer.smtp_settings              = mail_config['smtp_settings']
    end

    head = {}
    head[:to]        = recipient.email
    head[:from]      = newsletter.from

    head[:sender]    = newsletter.sender
    head[:reply_to]  = newsletter.reply_to
    
    prefix           = sending.is_a?(TestSending) ? "TEST: " : ""
    
    head[:subject]   =  [prefix, newsletter.subject].compact.join(' ')

    head["X-Sender"] = "MultiAdmin"
    head["X-MA-Id"]  = ["ma", sending.id, recipient.to_param].join('-')

    newsletter.attachments.each do |attachment|
       next unless File.exists?(attachment.path)
       attachments[attachment.name] = {
          :mime_type => attachment.content_type,
          :content => File.read(attachment.path)
        }
    end

    mail(head) do |format|
      data = { :subject => newsletter.subject, :content => newsletter.content.to_s.html_safe, :newsletter => newsletter, :recipient => recipient }
      if newsletter.has_text?
        format.text { render :inline => newsletter.template_text, :locals => data }
      end

      if newsletter.has_html?
        format.html { render :inline => newsletter.template_html, :locals => data }
      end
    end

  end

end
