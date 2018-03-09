module Admin
  class BuildMembershipType < ApplicationService
    input :success, default: ->(mtype) { mtype }

    require_permission :manage_users

    main do
      success.call MembershipType.new(position: next_highest_position)
    end

    private

    def next_highest_position
      (MembershipType.maximum(:position) || 0) + 1
    end
  end
end
