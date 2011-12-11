class NewsletterMailer < ActionMailer::Base

  def issue(newsletter, recipient, send_out_id = nil)
    account = newsletter.account
    NewsletterMailer.delivery_method            = account.mail_config['method'].to_sym
    NewsletterMailer.default_url_options[:host] = account.mail_config['host'] || $mail_config['host']
    NewsletterMailer.smtp_settings              = account.mail_config['smtp_settings']

    data = {
      :subject         => newsletter.subject,
      :content         => newsletter.content.to_s.html_safe,
      :newsletter      => newsletter,
      :recipient       => recipient,
      :send_out_id     => send_out_id.to_i,
      :newsletter_url  => newsletter_url(recipient.id.to_i, send_out_id.to_i),
      :tracking_url    => newsletter_url(recipient.id.to_i, send_out_id.to_i, :format => 'gif'),
      :unsubscribe_url => unsubscribe_url(recipient.confirm_code || 'dummy'),
    }

    head = {
      :to                => recipient.email,
      :from              => account.from,
      :sender            => account.sender,
      :reply_to          => account.reply_to,
      :subject           => data[:subject],
      "List-Unsubscribe" => "<#{data[:unsubscribe_url]}>",
      "X-Sender"         => "MultiAdmin - Nups",
    }

    newsletter.attachments.each do |attachment|
       next unless File.exists?(attachment.path)
       attachments[attachment.name] = {
         :mime_type => attachment.content_type,
         :content   => File.read(attachment.path),
       }
    end

    html_options = account.template_html.present? ? {:inline => account.template_html} : {:template => 'newsletter_mailer/issue.html'}
    text_options = account.template_text.present? ? {:inline => account.template_text} : {:template => 'newsletter_mailer/issue.text'}

    if @premailer
      html_content = render html_options.merge(:locals => data)
      html_content = Premailer.new(html_content, :with_html_string => true)
      mail(head) do |format|
        format.text { content.to_plain_text }
        format.html { content.to_inline_css }
      end
    else
      mail(head) do |format|
        format.text { render text_options.merge(:locals => data) }
        format.html { render html_options.merge(:locals => data) }
      end
    end
  end
end
