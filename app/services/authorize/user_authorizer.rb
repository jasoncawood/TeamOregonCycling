class Authorize
  class UserAuthorizer < Authorize
    main do
      validate_target
      denied! if is_deletion? && operating_on_self? && can_manage_users?
      authorized! if operating_on_self?
      authorized! if can_manage_users?
      denied!
    end

    private

    attr_accessor :can_manage_users

    def validate_target
      raise ArgumentError, "`on` must be of type `User`" unless on.is_a?(User)
    end

    def is_deletion?
      permission == :delete
    end

    def operating_on_self?
      context == on
    end

    def can_manage_users?
      return @can_manage_users if defined?(@can_manage_users)
      call_service(Authorize, permission: :manage_users,
                   authorized: -> { @can_manage_users = true },
                   not_authorized: -> { @can_manage_users = false })
      @can_manage_users
    end
  end
end
