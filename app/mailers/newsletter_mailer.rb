class NewsletterMailer < ActionMailer::Base

  def issue(newsletter, recipient)
    sending_id = "ma-#{newsletter.account.id}-#{newsletter.id}-#{recipient.id || 'test'}"

    if mail_config = newsletter.account.mail_config
      self.delivery_method            = mail_config['method'].to_sym
      self.default_url_options[:host] = mail_config['host']
      self.smtp_settings              = mail_config['smtp_settings']
    end

    template_html  = newsletter.template_html.blank? ? "<%= content %>" : newsletter.template_html
    template_text  = newsletter.template_text.blank? ? "<%= content %>" : newsletter.template_text

    head = {}
    head[:to]        = recipient.email
    head[:from]      = newsletter.from

    head[:sender]    = newsletter.sender
    head[:reply_to]  = newsletter.reply_to

    head[:subject]   = newsletter.subject
    head[:subject]   = "TEST: #{newsletter.subject}" if newsletter.test?

    head["X-Sender"] = "MultiAdmin"
    head["X-MA-Id"]  = sending_id

    mail(head) do |format|
      data = { :subject => newsletter.subject, :content => newsletter.content.to_s.html_safe, :newsletter => newsletter, :recipient => recipient }
      if newsletter.has_text?
        format.text { render :inline => template_text, :locals => data }
      end

      if newsletter.has_html?
        format.html { render :inline => template_html, :locals => data }
      end
    end

    newsletter.attachments.each do |attachment|
       attachments[attachment.name] = File.read(attachment.path) if File.exists?(attachment.path)
    end
  end

end
