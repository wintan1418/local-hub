class ContactMailer < ApplicationMailer
  def contact_message(name, email, subject, message)
    @name = name
    @email = email
    @subject = subject.presence || "General Inquiry"
    @message = message

    mail(
      to: ENV.fetch("SUPPORT_EMAIL", "support@localservicehub.com"),
      reply_to: email,
      subject: "Contact Form: #{@subject}"
    )
  end
end
