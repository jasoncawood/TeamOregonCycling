class AuthenticateUser < ApplicationService
  class AuthenticationFailed < RuntimeError; end
  class EmailNotConfirmed < RuntimeError; end

  input :email
  input :password
  input :success, default: ->(user:) { user }
  input :failed, default: -> { raise AuthenticationFailed }
  input :email_not_confirmed, default: -> { raise EmailNotConfirmed }

  authorization_policy allow_all: true

  main do
    find_matching_user
    authenticate_password
    check_for_confirmed_email
    success!
  end

  private

  attr_accessor :user

  def find_matching_user
    self.user = User.undiscarded.where(email: email).first
    failed! if user.nil?
  end

  def authenticate_password
    failed! unless user.authenticate(password)
  end

  def check_for_confirmed_email
    return unless user.confirmed_at.nil?

    run_callback(email_not_confirmed)
    stop!
  end

  def failed!
    run_callback(failed)
    stop!
  end

  def success!
    run_callback(success, user: user)
  end
end
