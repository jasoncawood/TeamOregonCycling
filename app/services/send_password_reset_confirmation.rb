class SendPasswordResetConfirmation < ApplicationService
  DAY_INTERVAL = 24 * 60 * 60

  input :email
  input :success
  input :not_found
  input :clock, default: Time

  authorization_policy allow_all: true

  main do
    find_matching_user
    generate_token
    send_reset_token_email
    run_callback(success, email)
  end

  private

  attr_accessor :user

  def find_matching_user
    self.user = User.find_by(email: email)

    if user.nil?
      run_callback(not_found, email)
      stop!
    end
  end

  def generate_token
    token = PasswordResetToken.new(email: email)
    token_expiration = clock.now + DAY_INTERVAL
    user.update_attributes!(
      password_reset_token: token,
      password_reset_token_expires_at: token_expiration
    )
  end

  def send_reset_token_email
    UserMailer.send_password_reset_confirmation(user: user)
  end
end
