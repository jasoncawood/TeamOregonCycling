class GetMembershipType < ApplicationService
  input :membership_type
  input :with_result, default: ->(mtype) { mtype }
  input :not_found, default: -> { raise NotFound, "MembershipType does not exist" }

  authorization_policy allow_all: true

  main do
    if existing_membership_type.present?
      self.result = existing_membership_type
      with_result.call(existing_membership_type)
    else
      not_found.call
    end
  end

  private

  def existing_membership_type
    @existing_membership_type ||= scope.where(id: membership_type_id).first
  end

  def membership_type_id
    @membership_type_id ||= case membership_type
                            when MembershipType then membership_type.id
                            when Integer, String then membership_type
                            else nil
                            end
  end

  def scope
    scope = nil
    call_service(Authorize, permission: :manage_users,
                 authorized: -> { scope = MembershipType.all },
                 not_authorized: -> { scope = MembershipType.kept })
    scope
  end
end
