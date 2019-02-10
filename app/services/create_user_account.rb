class CreateUserAccount < ApplicationService
  input :account_details
  input :success
  input :error

  authorization_policy allow_all: true

  main do
    validate_input
    create_account
  end

  private

  def validate_input
    unless account_details.valid?
      run_callback(error, account_details)
      stop!
    end
  end

  def create_account
    user = User.create(user_data)
    if user.valid?
      run_callback(success, user)
    else
      account_details.errors = user.errors
      run_callback(error, account_details)
    end
  end

  def user_data
    account_details
      .to_h
      .merge(confirmation_token: SecureRandom.hex(15))
  end
end
