class ContactForm < MailForm::Base
  Reason = Struct.new(:id, :label, keyword_init: true) do
    def to_label
      label
    end
  end

  VALID_REASONS = {
    general_inquiry: 'General Inquiry',
    membership_inquiry: 'Question about membership',
    account_help: 'Help with my account'
  }.map { |k,v| Reason.new(id: k.to_s, label: v) }

  def self.valid_reason_ids
    VALID_REASONS.map(&:id)
  end

  attributes :reason, validate: valid_reason_ids
  attributes :name, validate: true
  attributes :email, validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attributes :message, validate: true

  def valid_reasons
    VALID_REASONS
  end

  def headers
    {
      subject: "Team Oregon Contact Form - #{reason}",
      to: ENV.fetch('TEAMO_CONTACT_FORM_TO'),
      cc: email,
      from: email
    }
  end
end
