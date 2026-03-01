class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL', 'noreply@radiusapp.com')
  layout "mailer"
end
