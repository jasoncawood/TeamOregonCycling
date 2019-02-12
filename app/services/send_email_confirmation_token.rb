class SendEmailConfirmationToken < ApplicationService
  input :email
  input :message_sent, default: ->(_email_address) {}
  input :not_found, default: ->(_email_address) {}

  authorization_policy allow_all: true

  main do
    find_user
    generate_token
    send_message
  end

  private

  attr_accessor :user

  def find_user
    self.user = User.find_by(email: email)
    return unless user.nil?

    run_callback(not_found, email)
    stop!
  end

  def generate_token
    return unless user.confirmation_token.nil?

    token = EmailConfirmationToken.new(user.email)
    user.update_attributes!(confirmation_token: token)
  end

  def send_message
    UserMailer.with(user: user).email_confirmation.deliver_now
    run_callback(message_sent, email)
  end
end
