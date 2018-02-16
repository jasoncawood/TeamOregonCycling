class Authorize < BaseService
  input :permission
  input :authorized, default: -> { true }

  authorization_policy allow_all: true

  main do
    num_user_roles_with_permission = context.roles
      .where(['permissions @> ARRAY[:permission]', permission: permission])
      .count

    if num_user_roles_with_permission >= 1
      authorized.call
    else
      not_authorized.call
    end
  end
end
