class ListMembershipTypes < BaseService
  input :with_result, default: ->(m_types) { m_types }
  input :with_each, default: nil

  authorization_policy allow_all: true

  main do
    m_types = MembershipType.kept.order(:position).readonly
    m_types.each { |m_type| with_each.call(m_type) } if with_each.present?
    with_result.call(m_types)
  end
end
