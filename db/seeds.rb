MembershipType.create_with(
  position: 1,
  price: 65,
  description: <<-DESC).find_or_create_by!(name: 'Standard')
  Standard membership for adult team members.
  DESC

MembershipType.create_with(
  position: 2,
  price: 10,
  description: <<-DESC).find_or_create_by!(name: 'Student')
  Discounted membership for juniors and full-time students.

  Requires approval before membership will be activated. You will not be charged
  until after your membership is approved.
  DESC

MembershipType.create_with(
  position: 3,
  price: 10,
  description: <<-DESC).find_or_create_by!(name: 'Leadership')
  Discounted membership for those who volunteer to serve the team in a
  leadership role.

  Requires approval before membership will be activated. You will not be charged
  until after your membership is approved.
  DESC

admin_role = Role.create_with(permissions: Role::VALID_PERMISSIONS)
  .find_or_create_by!(name: 'Administrator')

admin_count = User.kept.joins(:roles).where(roles: { id: admin_role.id }).count

unless admin_count > 0
  User
    .create_with(first_name: 'Default', last_name: 'Administrator',
                 confirmed_at: Time.now, password: 'password',
                 roles: [admin_role])
    .find_or_create_by!(email: 'admin@example.com') do |u|

    u.undiscard
  end
end
