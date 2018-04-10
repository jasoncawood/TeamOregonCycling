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
      head :ok
    end
  end
end
