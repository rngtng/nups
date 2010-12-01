class NewsletterMailer < ActionMailer::Base

  def issue(newsletter, recipient)
    default_url_options[:host] = newsletter.host

    head = {}

    template_html  = newsletter.template_html.blank? ? "<%= content %>" : newsletter.template_html
    template_text  = newsletter.template_text.blank? ? "<%= content %>" : newsletter.template_text

    head[:to]      = recipient.email
    head[:from]    = newsletter.from

    head[:subject] = newsletter.subject
    head[:subject] = "TEST: #{subject}" if newsletter.test?

    head["X-Sender"] = "MultiAdmin"
    head["X-MA-Account-Id"] = newsletter.account.id

    mail(head) do |format|
      data = { :subject => subject, :content => newsletter.content.to_s.html_safe, :newsletter => newsletter, :recipient => recipient }
      if newsletter.has_html?
        format.html { render :inline => template_html, :locals => data }
      end

      if newsletter.has_text?
        format.text { render :inline => template_text, :locals => data }
      end
    end

    newsletter.attachments.each do |attachment|
       attachments[attachment.name] = File.read(attachment.path) if File.exists?(attachment.path)
    end
  end

end
