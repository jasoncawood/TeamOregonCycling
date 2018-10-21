module Admin
  class CreateUser < ApplicationService
    input :email
    input :first_name
    input :last_name
    input :role_ids
    input :success
    input :error

    require_permission :manage_users

    main do
      user = User.new(email: email,
               first_name: first_name,
               last_name: last_name,
               role_ids: role_ids)
      call_service(ValidateUser,
                   user: user,
                   purpose: :admin_create_user,
                   valid: callback(:user_validated),
                   invalid: callback(:user_invalid))
    end

    callback :user_validated do |user|
    end

    callback :user_invalid do |user|
    end
  end
end
