class DeviseMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    # Send Devise's confirmation email
    super
    
    # Queue welcome email to be sent after confirmation
    # We'll handle this in the User model callback instead
  end
end