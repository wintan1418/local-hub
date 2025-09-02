class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('FROM_EMAIL', 'noreply@localservicehub.com')
  layout "mailer"
end
