require 'the_help/service'

module Services
  module Admin
    class ListUsers < Service
      input :with_result, default: ->(users) { users }

      require_permission :manage_users

      main do
        users = User.order(:last_name, :first_name)
          .includes(:current_membership, :roles)
        with_result.call(users)
      end
    end
  end
end
