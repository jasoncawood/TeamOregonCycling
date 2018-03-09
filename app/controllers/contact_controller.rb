class ContactController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[new create]

  attr_accessor :contact_form
  private :contact_form=

  def new
    call_service(BuildContactForm, reason: params[:reason]) do |form|
      self.contact_form = form
    end
  end

  def create
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
end
