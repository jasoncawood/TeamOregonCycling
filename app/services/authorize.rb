class Authorize < BaseService
  input :permission
  input :on, default: nil
  input :authorized, default: -> { true }

  authorization_policy allow_all: true

  main do
    authorize_on_object ||
      authorize_permission
  end

  private

  def authorize_on_object
    return false if on.nil?
    authorizer = "Authorize::#{on.class.name}Authorizer".safe_constantize
    if authorizer.nil?
      not_authorized.call
    else
    call_service(authorizer, permission: permission, on: on,
                 authorized: authorized, not_authorized: not_authorized)
    end
    true
  end

  def authorize_permission
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
