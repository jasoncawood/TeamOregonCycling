module Admin
  class CreateMembership < ApplicationService
    input :membership_data
    input :success, default: ->(membership) { membership }
    input :failure, default: ->(membership) {
      raise Invalid, entity: membership
    }

    require_permission :manage_users

    main do
      membership = Membership.create(membership_data)
      if membership.valid?
        success.call(membership)
        self.result = membership
      else
        form = NewMembershipForm.new(membership,
                                     available_types: membership_types)
        failure.call(form)
      end
    end

    private

    def membership_types
      call_service(ListMembershipTypes)
    end
  end
end
