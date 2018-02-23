module Admin
  class BuildMembershipType < BaseService
    input :success, default: ->(mtype) { mtype }

    require_permission :manage_users

    main do
      success.call MembershipType.new(weight: next_highest_weight)
    end

    private

    def next_highest_weight
      MembershipType.maximum(:weight) + 1
    end
  end
end
