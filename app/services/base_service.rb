require 'the_help/service'

class BaseService < TheHelp::Service
  def self.require_permission(permission=nil, on: nil)
    authorization_policy do
      require_permission permission, on: on
    end
  end

  def require_permission(permission, on: nil)
    authorized = false
    args = {
      permission: permission,
      authorized: -> { authorized = true },
      not_authorized: -> { authorized = false }
    }
    args[:on] = send(on) unless on.nil?
    call_service(Authorize, **args)
    authorized
  end
end
