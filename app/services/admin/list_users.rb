module Admin
  class ListUsers < ApplicationService
    input :with_result, default: ->(users) { users }

    require_permission :manage_users

    main do
      users = User.kept.order(:last_name, :first_name)
        .includes(:current_membership, :roles)
        .readonly
      with_result.call(users)
    end
  end
end
