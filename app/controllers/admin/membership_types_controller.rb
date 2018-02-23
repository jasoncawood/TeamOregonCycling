module Admin
  class MembershipTypesController < Admin::BaseController
    attr_accessor :membership_types, :membership_type
    private :membership_types=, :membership_type=

    show_admin_sidebar_manage_users!
    currently_managing :membership_types

    def index
      call_service(ListMembershipTypes, with_result: method(:membership_types=))
    end

    def new
      call_service(Admin::BuildMembershipType,
                   success: method(:membership_type=))
    end

    def create
      call_service(Admin::CreateMembershipType,
                   data: membership_type_params,
                   success: method(:membership_type_created),
                   error: method(:error_creating_membership_type))
    end

    def destroy
      call_service(Admin::DeleteMembershipType,
                   membership_type: params[:id],
                   success: method(:membership_type=))
      flash[:alert] = "The Membership Type '#{membership_type.name}' has been removed."
      redirect_to admin_membership_types_path
    end

    private

    def membership_type_created(membership_type)
      flash[:info] = 'Membership Type was created'
      redirect_to admin_membership_types_path
    end

    def error_creating_membership_type(membership_type)
      flash[:error] = 'Unable to create new Membership Type'
      self.membership_type = membership_type
      render action: :new
    end

    def membership_type_params
      params.require(:membership_type)
        .permit(:name, :description, :price, :position, :approval_required)
    end
  end
end
