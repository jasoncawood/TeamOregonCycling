class NewEmailConfirmationTokenForm
  include ActiveModel::Model

  attr_accessor :email_address

  validates :email_address,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: 'only allows valid emails'
            }
end
