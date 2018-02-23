module Admin
  class MembershipTypesController < Admin::BaseController
    attr_accessor :membership_types
    private :membership_types=

    show_admin_sidebar_manage_users!
    currently_managing :membership_types

    def index
      call_service(ListMembershipTypes, with_result: method(:membership_types=))
    end

    def new
      call_service(Admin::BuildMembershipType,
                   with_result: method(:membership_type=))
    end
  end
end
