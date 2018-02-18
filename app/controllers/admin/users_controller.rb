module Admin
  class UsersController < BaseController
    attr_accessor :users, :user, :memberships
    private :users=, :user=, :memberships=

    def index
      call_service(Admin::ListUsers,
                   with_result: ->(users) { self.users = users })
    end

    def show
      call_service(Admin::GetUserDetails, user: params[:id],
                   with_result: method(:user=))
      call_service(Admin::ListMembershipHistory, user: user,
                   with_result: method(:memberships=))
    end

    def edit
      call_service(Admin::GetUserDetails, user: params[:id],
                   with_result: method(:user=))
    end

    def update
      redirect_to admin_user_path(params[:id])
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
