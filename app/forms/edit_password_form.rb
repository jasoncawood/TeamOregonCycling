class EditPasswordForm
  include ActiveModel::Model

  attr_accessor :password, :password_confirmation

  validates :password, :password_confirmation, presence: true

  validates :password, confirmation: true
end
