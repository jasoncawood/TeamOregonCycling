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
      if user.update_attributes(changes)
        success.call(user)
      else
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
