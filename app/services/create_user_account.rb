class CreateUserAccount < ApplicationService
  input :account_details
  input :success
  input :error

  authorization_policy allow_all: true

  main do
    create_account
    send_email_confirmation
    success!
  end

  private

  attr_accessor :user

  def create_account
    self.user = User.create(account_details.to_h)
    return if user.valid?

    run_callback(error, user.errors)
    stop!
  end

  def send_email_confirmation
    call_service(SendEmailConfirmationToken, email: user.email)
  end

  def success!
    run_callback(success, user)
  end
end
