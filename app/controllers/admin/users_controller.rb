module Admin
  class UsersController < BaseController
    attr_accessor :users
    private :users=

    def index
      call_service(Admin::ListUsers,
                   with_result: ->(users) { self.users = users })
    end
  end
end
