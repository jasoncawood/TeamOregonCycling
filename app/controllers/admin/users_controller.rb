module Admin
  class UsersController < BaseController
    attr_accessor :users, :user, :memberships
    private :users=, :user=, :memberships=

    require_permission(:manage_users)

    show_admin_sidebar_manage_users!
    currently_managing :users

    def index
      call_service(Admin::ListUsers,
                   with_result: ->(users) { self.users = users })
    end

    def show
      call_service(GetUser, user: params[:id],
                   with_result: method(:user=))
      call_service(ListMembershipHistory, user: user,
                   with_result: method(:memberships=))
      render 'users/show'
    end

    def edit
      call_service(GetUser, user: params[:id],
                   with_result: method(:user=))
    end

    def update
      call_service(Admin::UpdateUser, user: params[:id], changes: user_params,
                   success: method(:user_updated),
                   error: method(:user_update_error))
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

    def user_updated(user)
      flash[:notice] = "The user #{user.display_name} has been updated."
      redirect_to admin_users_path
    end

    def user_update_error(user)
      self.user = user
      render action: :edit
    end

    def user_params
      params.require(:user)
        .permit(:email, :first_name, :last_name, :password,
                :password_confirmation, :added_to_mailing_list, :invited_to_slack,
                role_ids: [])
        .reject { |key, value|
        %w[password password_confirmation].include?(key) &&
          value.blank?
      }
    end
  end
end
