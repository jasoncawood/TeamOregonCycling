class Authorize
  class UserAuthorizer < Authorize
    main do
      validate_target
      deny_user_manager_self_deletion
      authorize_permission(:manage_users)
    end

    private

    def validate_target
      raise ArgumentError, "`on` must be of type `User`" unless on.is_a?(User)
    end

    def deny_user_manager_self_deletion
      return unless context == on
      call_service(Authorize, permission: :manage_users,
                   authorized: not_authorized,
                   not_authorized: authorized)
      stop!
    end
  end
end
