class EmailConfirmationForm
  include ActiveModel::Model

  attr_accessor :confirmation_token

  def model_name
    ActiveModel::Name.new(self.class, nil, 'email_confirmation')
  end

  validates :confirmation_token, presence: true
end
