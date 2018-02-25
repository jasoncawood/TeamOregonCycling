module Admin
  class UpdateMembershipType < BaseService
    input :membership_type
    input :data
    input :success, default: ->(mtype) { mtype }
    input :error, default: ->(mtype) { raise Invalid, entity: mtype }

    require_permission :manage_users

    main do
      if found_membership_type.update_attributes(data)
        success.call(found_membership_type)
      else
        error.call(found_membership_type)
      end
    end

    private

    def found_membership_type
      return @found_membership_type if defined?(@found_membership_type)
      call_service(GetMembershipType,
                   membership_type: membership_type,
                   with_result: ->(mtype) { @found_membership_type = mtype })
      @found_membership_type
    end
  end
end
