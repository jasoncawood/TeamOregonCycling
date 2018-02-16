require 'the_help/service'

class BaseService < TheHelp::Service
  def self.require_permission(permission)
    authorization_policy do
      authorized = false
      call_service(Authorize, permission: permission,
                   authorized: -> { authorized = true },
                   not_authorized: -> { authorized = false })
      authorized
    end
  end
end
