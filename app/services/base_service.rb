class BaseService < TheHelp::Service
  class NotFound < StandardError
    attr_reader :entity_type, :id

    def initialize(message='', entity_type: 'Entity', id: nil)
      self.entity_type = entity_type
      self.id = id
      message += " Unable to find #{entity_type} with id #{id}."
      super(message)
    end

    private

    attr_writer :entity_type, :id
  end

  class Invalid < StandardError
    attr_reader :entity

    def initialize(message='', entity:)
      self.entity = entity
      message += "Invalid #{entity_type}. #{errors.join(', ')}"
      super(message)
    end

    private

    attr_writer :entity

    def entity_type
      entity.class.name
    end

    def errors
      entity.errors.full_messages
    end
  end

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
