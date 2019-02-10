require 'active_model'

class NewUserForm
  include ActiveModel::Model

  FIELDS = :email, :password, :password_confirmation, :first_name, :last_name

  attr_accessor *FIELDS

  def model_name
    ActiveModel::Name.new(self.class, nil, 'new_user')
  end

  validates :email, :password, :password_confirmation, :first_name,
    :last_name,
    presence: true

  validates :password, confirmation: true
end
