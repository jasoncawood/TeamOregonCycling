class LoadCurrentUser < ApplicationService
  input :user_id
  input :success, default: ->(user) { user }

  authorization_policy allow_all: true

  main do
    stop! if user_id.nil?
    if (user = User.undiscarded.where(id: user_id).first)
      success.call(user)
    end
  end
end
