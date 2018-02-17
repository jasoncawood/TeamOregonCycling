module Admin
  class DeleteUser < BaseService
    input :user
    input :success, default: ->(user) { user }

    require_permission :delete, on: :user

    main do
      user.destroy
      success.call(user)
    end

    private

    def user
      return @user if @user.is_a?(User)
      @user = User.find(@user)
    end
  end
end
