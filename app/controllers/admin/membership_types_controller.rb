module Admin
  class MembershipTypesController < Admin::BaseController
    attr_accessor :membership_types, :membership_type
    private :membership_types=, :membership_type=

    show_admin_sidebar_manage_users!
    currently_managing :membership_types

    def index
      call_service(ListMembershipTypes, with_result: method(:membership_types=))
    end

    def deleted
      self.admin_heading = 'Showing deleted membership types'
      call_service(ListMembershipTypes, only_deleted: true,
                   with_result: method(:membership_types=))
      render action: :index
    end

    def new
      call_service(Admin::BuildMembershipType,
                   success: method(:membership_type=))
    end

    def create
      call_service(Admin::CreateMembershipType,
                   data: membership_type_params,
                   success: method(:membership_type=),
                   error: method(:error_creating_membership_type))
      flash[:success] = 'Membership Type was created'
      redirect_to admin_membership_types_path
    end

    def edit
      call_service(GetMembershipType,
                   membership_type: params[:id],
                   with_result: method(:membership_type=),
                   not_found: method(:render_404))
    end

    def update
      call_service(UpdateMembershipType,
                   membership_type: params[:id],
                   data: membership_type_params,
                   success: method(:membership_type=),
                   error: method(:error_updating_membership_type))
      flash[:success] = 'The membership type has been updated.'
      redirect_to admin_membership_types_path
    end

    def destroy
      call_service(Admin::DeleteMembershipType,
                   membership_type: params[:id],
                   success: method(:membership_type=))
      flash[:alert] = "The Membership Type '#{membership_type.name}' has " \
                      'been removed.'
      redirect_to admin_membership_types_path
    end

    def undelete
      call_service(Admin::UndeleteMembershipType,
                   membership_type: params[:id],
                   success: method(:membership_type=))
      flash[:success] = "The Membership Type '#{membership_type.name}' has " \
                        'been restored.'
      redirect_to admin_membership_types_path
    end

    private

    def error_creating_membership_type(membership_type)
      flash[:error] = 'Unable to create new Membership Type'
      self.membership_type = membership_type
      render action: :new
      halt!
    end

    def error_updating_membership_type(membership_type)
      flash[:error] = 'Unable to update the Membership Type'
      self.membership_type = membership_type
      render action: :edit
      halt!
    end

    def membership_type_params
      params.require(:membership_type)
        .permit(:name, :description, :price, :position, :approval_required)
    end
  end
end
