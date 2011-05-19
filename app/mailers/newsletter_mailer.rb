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

    head[:subject]   = [prefix, newsletter.subject].compact.join(' ')

    head["X-Sender"] = "MultiAdmin"
    head["X-MA-Id"]  = ["ma", sending.id, recipient.id || 'test'].join('-')

    newsletter.attachments.each do |attachment|
       next unless File.exists?(attachment.path)
       attachments[attachment.name] = {
         :mime_type => attachment.content_type,
         :content => File.read(attachment.path)
       }
    end

    data    = { :subject => newsletter.subject, :content => newsletter.content.to_s.html_safe, :newsletter => newsletter, :recipient => recipient }
    content = render(:inline => newsletter.template_html, :locals => data)
    content = Premailer.new( content, :with_html_string => true )

    mail(head) do |format|
      format.text { content.to_plain_text }
      format.html { content.to_inline_css }
    end

  end

end
