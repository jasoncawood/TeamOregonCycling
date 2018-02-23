class ListMembershipTypes < BaseService
  input :only_deleted, default: false
  input :with_result, default: ->(m_types) { m_types }
  input :with_each, default: nil

  authorization_policy do
    break true unless only_deleted
    require_permission :manage_users
  end

  main do
    scope = if only_deleted
              MembershipType.discarded
            else
              MembershipType.kept
            end
    m_types = scope.order(:position).readonly
    m_types.each { |m_type| with_each.call(m_type) } if with_each.present?
    with_result.call(m_types)
  end
end
