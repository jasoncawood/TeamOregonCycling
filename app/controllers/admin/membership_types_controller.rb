module Admin
  class MembershipTypesController < Admin::BaseController
    attr_accessor :membership_types
    private :membership_types=

    show_admin_sidebar_manage_users!

    def index
      call_service(ListMembershipTypes, with_result: method(:membership_types=))
    end
  end
end
