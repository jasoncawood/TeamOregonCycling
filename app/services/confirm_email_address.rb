class ConfirmEmailAddress < ApplicationService
  input :confirmation_token
  input :email_confirmed, default: -> {}
  input :invalid, default: -> { raise 'unable to confirm email address' }
  input :clock, default: Time

  authorization_policy allow_all: true

  main do
    find_matching_user
    update_confirmation_status
    run_callback email_confirmed
  end

  private

  attr_accessor :user

  def find_matching_user
    self.user = User.find_by(confirmation_token: confirmation_token)
    invalid! if user.nil?
  end

  def invalid!
    run_callback(invalid)
    stop!
  end

  def update_confirmation_status
    user.update_attributes!(
      confirmation_token: nil,
      confirmed_at: clock.now
    )
  end
end
