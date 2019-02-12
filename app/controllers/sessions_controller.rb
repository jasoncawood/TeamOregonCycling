class SessionsController < ApplicationController
  def create
    call_service(AuthenticateUser,
                 email: session_params[:email],
                 password: session_params[:password],
                 success: callback(:authenticated),
                 email_not_confirmed: callback(:email_not_confirmed),
                 failed: callback(:authentication_failed))
  end

  def destroy
    reset_session
    flash[:notice] = 'You have been signed out.'
    redirect_to root_path
  end

  def email_confirmation_form
    @email_confirmation = EmailConfirmationForm.new(
      params.permit(:confirmation_token)
    )
  end

  def email_confirmation
    code = params
      .require(:email_confirmation)
      .require(:confirmation_token)
    call_service(ConfirmEmailAddress,
                 confirmation_token: code,
                 email_confirmed: callback(:email_confirmed),
                 invalid: callback(:invalid_confirmation_token))
  end

  def send_new_email_confirmation_form
    @send_new_email_confirmation = NewEmailConfirmationTokenForm.new
  end

  def send_new_email_confirmation
    email_address = params
      .require(:new_email_confirmation_token_form)
      .require(:email_address)
    call_service(SendEmailConfirmationToken,
                 email: email_address,
                 message_sent: callback(:new_token_sent),
                 not_found: callback(:new_token_sent))
  end

  callback :authentication_failed do
    flash[:error] = 'The email and/or password you entered are not correct.'
    redirect_to new_session_path
  end

  callback :authenticated do |user:|
    self.current_user = user
    redirect_to post_authentication_url
  end

  callback :email_not_confirmed do
    flash[:error] = 'You need to confirm your email address before you can ' \
                    'log in.'
    redirect_to email_confirmation_path
  end

  callback(:email_confirmed) do
    flash[:info] = 'Thank you for confirming your email address. You may ' \
                   'now log in.'
    redirect_to new_session_path
    halt!
  end

  callback(:invalid_confirmation_token) do |error|
    flash.now[:error] = error
    render action: :email_confirmation_token
    halt!
  end

  callback(:new_token_sent) do |email|
    flash[:info] = "If there is an account associated with #{email}, we " \
                   'have generated a new confirmation code and sent it to ' \
                   'that address.'
    redirect_to email_confirmation_path
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end

  def post_authentication_url
    session.delete(:post_authentication_url) || root_path
  end

end
