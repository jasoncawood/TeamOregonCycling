class UsersController < ApplicationController
  attr_accessor :user, :memberships
  private :user=, :memberships=

  class NewUserForm
    include ActiveModel::Model

    FIELDS = :email, :password, :password_confirmation, :first_name, :last_name

    attr_accessor *FIELDS

    def model_name
      ActiveModel::Name.new(self.class, nil, 'new_user')
    end

    def to_h
      {
        email: email,
        password: password,
        first_name: first_name,
        last_name: last_name
      }
    end

    def errors=(new_errors)
      @errors = new_errors
    end

    validates :email, :password, :password_confirmation, :first_name,
      :last_name,
      presence: true

    validates :password, confirmation: true
  end

  def new
    render locals: { user: NewUserForm.new }
  end

  def create
    new_user = NewUserForm.new(
      params
      .require(:new_user)
      .permit(*NewUserForm::FIELDS)
    )

    call_service(CreateUserAccount, account_details: new_user,
                 success: method(:account_created),
                 error: method(:account_creation_error))
  end

  def show
    require_permission(:show, on: current_user)
    self.user = current_user
    call_service(ListMembershipHistory,
                 user: current_user, with_result: method(:memberships=))
  end

  private

  def account_created(user)
    self.current_user = user
    redirect_to user_path
  end

  def account_creation_error(new_user)
    flash.now[:error] = 'There was an error while creating your account.'
    render action: :new, locals: { user: new_user }
  end
end
