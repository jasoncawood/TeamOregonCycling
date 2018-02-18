module Admin
  class UpdateUser < BaseService
    input :user
    input :changes
    input :success, default: ->(user) { user }
    input :error, default: ->(user) {
      raise 'Unable to save changes due to errors. ' \
            "#{user.errors.full_messages.join(', ')}"
    }

    require_permission :update, on: :user

    main do
      authorize_changes_to_user_roles
      if user.update_attributes(changes)
        user.readonly!
        success.call(user)
      else
        user.readonly!
        error.call(user)
      end
    end

    private

    def user
      return @user if @user.is_a?(User)
      @user = User.find(@user)
    end

    def authorize_changes_to_user_roles
      return unless changes.key?(:role_ids) || changes.key?(:roles)
      authorized = false
      call_service(Authorize, permission: :manage_users,
                   authorized: -> { authorized = true },
                   not_authorized: -> { authorized = false })
      return if authorized
      user.errors.add(:roles, :not_authorized,
                      message: 'You are not authorized to modify the roles ' \
                      'for this user.')
      error.call(user)
      stop!
    end
  end
end
