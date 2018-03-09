class ContactTeam < ApplicationService
  input :message

  authorization_policy allow_all: true

  main do
    self.result = ContactForm.new(message)
    unless result.valid?
      invalid_input.call(result)
      stop!
    end
    result.deliver
  end
end
