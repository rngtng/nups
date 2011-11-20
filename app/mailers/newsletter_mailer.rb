class NewsletterMailer < ActionMailer::Base

  def issue(newsletter, recipient)

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

    head[:subject]   = [newsletter.subject].compact.join(' ')

    head["X-Sender"] = "MultiAdmin"

    newsletter.attachments.each do |attachment|
       next unless File.exists?(attachment.path)
       attachments[attachment.name] = {
         :mime_type => attachment.content_type,
         :content   => File.read(attachment.path)
       }
    end

    data = {
      :subject    => newsletter.subject,
      :content    => newsletter.content.to_s.html_safe,
      :newsletter => newsletter,
      :recipient  => recipient
    }
    content = render(:inline => newsletter.template, :locals => data)

    if @premailer
      content = Premailer.new(content, :with_html_string => true)
      mail(head) do |format|
        format.text { content.to_plain_text }
        format.html { content.to_inline_css }
      end
    else
      mail(head) do |format|
        format.text { render :text => "" }
        format.html { content }
      end
    end
  end

end
