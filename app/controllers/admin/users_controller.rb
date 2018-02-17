module Admin
  class UsersController < BaseController
    attr_accessor :users
    private :users=

    def index
      call_service(Admin::ListUsers,
                   with_result: ->(users) { self.users = users })
    end

    def destroy
      call_service(Admin::DeleteUser, user: params[:id],
                   success: method(:user_deleted))
    end

    private

    def user_deleted(user)
      flash[:notice] = "The user #{user.display_name} has been deleted."
      redirect_to admin_users_path
    end
  end
end
