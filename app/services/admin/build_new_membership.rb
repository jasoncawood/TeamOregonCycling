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

    class NewMembershipForm < SimpleDelegator
      attr_accessor :available_types
      private :available_types=

      def initialize(membership, available_types:)
        super(membership)
        self.available_types = available_types
      end

      delegate :display_name, to: :user, prefix: true
    end
  end
end
