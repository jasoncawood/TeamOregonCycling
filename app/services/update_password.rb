class UpdatePassword < ApplicationService
  input :user
  input :new_password
  input :success

  require_permission :change_password, on: :user

  main do
    get_user
    update_password
    run_callback(success)
  end

  private

  attr_accessor :user

  def get_user
    call_service(GetUser, user: user, allow_update: true,
                 with_result: callback(:user=))
  end

  def update_password
    user.update_attributes!(password: new_password)
  end
end
