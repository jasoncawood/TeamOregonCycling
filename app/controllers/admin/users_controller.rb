module Admin
  class UsersController < BaseController
    attr_accessor :users, :user, :memberships
    private :users=, :user=, :memberships=

    require_permission(:manage_users)

    show_admin_sidebar_manage_users!
    currently_managing :users

    def index
      call_service(Admin::ListUsers,
                   with_result: callback(:users=))
    end

    def show
      call_service(Admin::GetUserDetails,
                   user: params[:id],
                   with_result: callback(:user=))
      call_service(Admin::ListMembershipHistory,
                   user: user,
                   with_result: callback(:memberships=))
    end

    def new
      self.user = User.new
    end

    def create
      call_service(Admin::CreateUser, **user_params,
                   success: callback(:user_created),
                   error: callback(:user_creation_error))
    end

    callback :user_created do |user|
      flash[:notice] = "The user #{user.display_name} has been created."
      redirect_to admin_user_path(user)
    end

    callback :user_creation_error do |user|
      self.user = user
      render action: :new
    end

    def edit
      call_service(Admin::GetUserDetails,
                   user: params[:id],
                   with_result: callback(:user=))
    end

    def update
      call_service(Admin::UpdateUser,
                   user: params[:id],
                   changes: user_params,
                   success: callback(:user_updated),
                   error: callback(:user_update_error))
    end

    callback :user_updated do |user|
      flash[:notice] = "The user #{user.display_name} has been updated."
      redirect_to admin_users_path
    end

    callback :user_update_error do |user|
      self.user = user
      render action: :edit
    end

    def destroy
      call_service(Admin::DeleteUser,
                   user: params[:id],
                   success: callback(:user_deleted))
    end

    callback :user_deleted do |user|
      flash[:notice] = "The user #{user.display_name} has been deleted."
      redirect_to admin_users_path
    end

    private

    def user_params
      params
        .require(:user)
        .permit(:email, :first_name, :last_name, :password,
                :password_confirmation, role_ids: [])
        .reject { |key, value|
          %w[password password_confirmation].include?(key) && value.blank?
        }
        .to_h
        .symbolize_keys
    end
  end
end
