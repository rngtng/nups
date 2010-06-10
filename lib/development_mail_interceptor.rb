class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "DEVMODE: #{message.to} #{message.subject}"
    message.to = "error@c-art-web.de"
  end
end