admin_role = Role.create_with(permissions: Role::VALID_PERMISSIONS)
  .find_or_create_by!(name: 'Administrator')

User.create_with(first_name: 'Default', last_name: 'Administrator',
                 password: 'password', roles: [admin_role])
  .find_or_create_by!(email: 'admin@example.com').confirm
