module Admin
  class UsersController < BaseController
    attr_accessor :users
    private :users=

    def index
      call_service(Services::Admin::ListUsers,
                   with_result: ->(users) { self.users = users })
    end
  end
end
