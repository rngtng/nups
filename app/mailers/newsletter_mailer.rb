class NewsletterMailer < ActionMailer::Base
  TRACK_IMG = %{<img src="<%= public_newsletter_url(recipient.id, send_out_id, :format => 'gif') %>" width="1" height="1">}
  TRACK_URL = %{<%= public_newsletter_url(recipient.id, send_out_id) %>}

  def issue(newsletter, recipient, send_out_id = nil)

    if mail_config = newsletter.account.mail_config
      NewsletterMailer.delivery_method            = mail_config['method'].to_sym
      NewsletterMailer.default_url_options[:host] = mail_config['host'] || 'www2.multiadmin.de:8080'
      NewsletterMailer.smtp_settings              = mail_config['smtp_settings']
    end

    head = {}
    head[:to]        = recipient.email
    head[:from]      = newsletter.from

    head[:sender]    = newsletter.sender
    head[:reply_to]  = newsletter.reply_to

    head[:subject]   = [newsletter.subject].compact.join(' ')

    head["X-Sender"] = "MultiAdmin - Nups"

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
      :recipient  => recipient,
      :send_out_id => send_out_id
    }

    template_text = "#{newsletter.template_text}#{TRACK_URL if recipient.id && send_out_id}"
    template_html = "#{newsletter.template}#{TRACK_IMG if recipient.id && send_out_id}"

    if @premailer
      html_content = render(:inline => template_html, :locals => data)
      html_content = Premailer.new(html_content, :with_html_string => true)
      mail(head) do |format|
        format.text { content.to_plain_text }
        format.html { content.to_inline_css }
      end
    else
      mail(head) do |format|
        format.text { render(:inline => template_text, :locals => data) }
        format.html { render(:inline => template_html, :locals => data) }
      end
    end
  end

end
