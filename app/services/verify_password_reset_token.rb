class VerifyPasswordResetToken < ApplicationService
  input :token
  input :success
  input :invalid

  authorization_policy allow_all: true

  main do
    find_user
    invalidate_token
    run_callback(success, user)
  end

  private

  attr_accessor :user

  def find_user
    self.user = User.find_by('password_reset_token = :token AND ' \
                             'password_reset_token_expires_at > NOW()',
                             token: token)
    return unless user.nil?

    run_callback(invalid)
    stop!
  end

  def invalidate_token
    user.update_attributes!(password_reset_token: nil,
                            password_reset_token_expires_at: nil)
  end
end
