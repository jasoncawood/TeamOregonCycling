class GetUser < ApplicationService
  input :user
  input :allow_update, default: false
  input :with_result, default: ->(user) { user }

  require_permission :show, on: :user

  main do
    with_result.call(user)
    self.result = user
  end

  private

  def user
    @user = User.find(@user.to_param)
    @user.readonly! unless allow_update
    @user
  end
end
