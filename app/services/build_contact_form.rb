class BuildContactForm < ApplicationService
  input :reason, default: 'general_inquiry'

  authorization_policy allow_all: true

  main do
    self.result = ContactForm.new(reason: valid_reason)
  end

  private

  def valid_reason
    r = reason.to_s
    ContactForm.valid_reason_ids.include?(r) ? r : 'general_inquiry'
  end
end
