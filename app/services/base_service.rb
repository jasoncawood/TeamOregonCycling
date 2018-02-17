require 'the_help/service'

class BaseService < TheHelp::Service
  def self.require_permission(permission, on: nil)
    authorization_policy do
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
end
