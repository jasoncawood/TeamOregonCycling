module Admin
  class UpdateUser < BaseService
    input :user
    input :changes
    input :success, default: ->(user) { user }
    input :error, default: ->(user) {
      raise 'Unable to save changes due to errors. ' \
            "#{user.errors.full_messages.join(', ')}"
    }

    authorization_policy do
      tests = [require_permission(:update, on: :user)]
      if changes.key?(:roles) || changes.key?(:role_ids)
        tests << require_permission(:manage_users)
      end
      tests.all?
    end

    main do
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
  end
end
