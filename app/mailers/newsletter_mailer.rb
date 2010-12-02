class NewsletterMailer < ActionMailer::Base

  def issue(newsletter, recipient)
    default_url_options[:host] = newsletter.host

    template_html  = newsletter.template_html.blank? ? "<%= content %>" : newsletter.template_html
    template_text  = newsletter.template_text.blank? ? "<%= content %>" : newsletter.template_text

    head = {}
    head[:to]      = recipient.email
    head[:from]    = newsletter.from

    #head[:sender]  = "cartspam+ma-#{newsletter.account.id}-#{newsletter.id}-#{recipient.id || test}@gmail.com" #nups bounce
    head[:sender]  = "ma-#{newsletter.account.id}-#{newsletter.id}-#{recipient.id || 'test'}@bounces.multiadmin.de" #nups bounce

    head[:reply_to]  = "info@millioneninvest.de"

    head[:subject] = newsletter.subject
    head[:subject] = "TEST: #{newsletter.subject}" if newsletter.test?

    head["X-Sender"] = "MultiAdmin"
    head["X-MA-Account-Id"] = newsletter.account.id.to_s

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
