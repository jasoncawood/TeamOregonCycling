module Admin
  class BuildNewMembership < ApplicationService
    input :user

    require_permission :manage_users

    main do
      self.result = NewMembershipForm.new(
        membership,
        available_types: membership_types
      )
    end

    private

    def membership
      Membership.new(user: load_user,
                     starts_on: Date.today,
                     ends_on: Date.today + 1.year)
    end

    def load_user
      call_service(GetUserDetails, user: user)
    end

    def membership_types
      call_service(ListMembershipTypes)
    end
  end
end
