class Authorize < BaseService
  input :permission
  input :on, default: nil
  input :authorized, default: -> { true }

  authorization_policy allow_all: true

  main do
    authorize_on_object
    authorize_permission(permission)
  end

  private

  def authorize_on_object
    return if on.nil?
    authorizer = "Authorize::#{on.class.name}Authorizer".safe_constantize
    denied! if authorizer.nil?
    call_service(authorizer, permission: permission, on: on,
                 authorized: authorized, not_authorized: not_authorized)
    stop!
  end

  def authorize_permission(permission)
    num_user_roles_with_permission = context.roles
      .where(['permissions @> ARRAY[:permission]', permission: permission])
      .count
    authorized! if num_user_roles_with_permission >= 1
    denied!
  end

  def authorized!
    authorized.call
    stop!
  end

  def denied!
    not_authorized.call
    stop!
  end
end
