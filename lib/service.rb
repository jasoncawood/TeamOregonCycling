class Service < TheHelp::Service
  def self.require_permission(permission)
    authorization_policy do
      authorized = false
      call_service(Services::Authorize, permission: permission,
                   authorized: -> { authorized = true },
                   not_authorized: -> { authorized = false })
      authorized
    end
  end
end
