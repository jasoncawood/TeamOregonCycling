class AuthenticateUser < ApplicationService
  class AuthenticationFailed < RuntimeError; end

  input :email
  input :password
  input :success, default: ->(user:) { user }
  input :failed, default: -> { raise AuthenticationFailed }

  authorization_policy allow_all: true

  main do
    user = User.undiscarded.where(email: email).first
    if user&.authenticate(password)
      success.call(user: user)
    else
      failed.call
    end
  end
end
