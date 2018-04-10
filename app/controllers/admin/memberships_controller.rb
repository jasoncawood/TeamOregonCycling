module Admin
  class MembershipsController < Admin::BaseController
    attr_accessor :membership
    helper_method :membership
    private :membership=

    currently_managing :users
    show_admin_sidebar_manage_users!

    def new
      self.membership = call_service(BuildNewMembership, user: params[:user_id])
    end

    def create
      call_service(CreateMembership, membership_data: membership_params,
                   success: method(:membership=),
                   failure: method(:failed_to_create_membership))
      flash[:success] = "Added new membership for #{membership.user_display_name}"
      redirect_to admin_user_path(id: membership.user)
    end

    private

    def membership_params
      params
        .require(:membership)
        .permit(:user_id, :membership_type_id, :starts_on, :ends_on,
                :amount_paid)
    end

    def failed_to_create_membership(membership)
      self.membership = membership
      flash[:error] = 'An error occured while adding the membership.'
      render action: :new
      halt!
    end
  end
end
