class ContactController < ApplicationController
  attr_accessor :contact_form
  private :contact_form=

  def new
    call_service(BuildContactForm, reason: params[:reason]) do |form|
      self.contact_form = form
    end
  end

  def create
    validate_recaptcha('contact_form')
    call_service(ContactTeam, message: message_params,
                 invalid_input: method(:message_invalid)) do |form|
      self.contact_form = form
    end
  end

  private

  def message_invalid(form)
    self.contact_form = form
    flash[:error] = 'Your message is invalid and could not be sent.'
    render action: :new
  end

  def message_params
    params
      .require(:contact_form)
      .permit(:reason, :name, :email, :message)
  end

  def validate_recaptcha(action_name)
    return if NewGoogleRecaptcha.human?(params[:new_google_recaptcha_token],
                                        action_name)
    new
    contact_form.errors.add(
      :base,
      'According to Google, you appear to be a script rather than a person. ' \
      'Please try again later.'
    )
    render action: :new
    halt!
  end
end
