class ListMembershipTypes < BaseService
  input :with_each, default: ->(m_type) { m_type }

  authorization_policy allow_all: true

  main do
    MembershipType.kept.order(:weight).readonly
      .each { |m_type| with_each.call(m_type) }
  end
end
