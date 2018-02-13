module Admin
  class UsersController < BaseController
    def index
      require_permission :manage_users
    end
  end
end
