module Admin
  class CreateMembershipType < ApplicationService
    class Invalid < StandardError; end

    input :data
    input :success, default: ->(mtype) { mtype }
    input :error, default: ->(invalid_mtype) {
      raise Invalid, invalid_mtype.errors.full_messages.join(', ')
    }

    require_permission :manage_users

    main do
      result = MembershipType.create(data)
      if result.valid?
        success.call(result)
      else
        error.call(result)
      end
    end
  end
end
