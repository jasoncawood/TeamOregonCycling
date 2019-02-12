module Admin
  class ListMembershipHistory < ApplicationService
    input :user
    input :with_result, default: -> (memberships) { memberships }

    require_permission :view_membership_history, on: :user

    main do
      memberships = user.memberships
        .order(ends_on: 'DESC')
        .readonly
      with_result.call(memberships)
    end

    private

    def user
      return @user if @user.is_a?(User)
      @user = User.find(@user)
    end
  end
end
