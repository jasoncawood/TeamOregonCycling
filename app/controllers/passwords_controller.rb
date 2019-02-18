class PasswordsController < ApplicationController
  require_permission :update_password,
                     on: :current_user,
                     except: %i[reset send_reset verify_reset]

  def reset
    if current_user.anonymous?
      reset_password_form = ResetPasswordForm.new
      render locals: { form: reset_password_form }
    else
      redirect_to edit_password_path
    end
  end

  def send_reset
    reset_password_form = ResetPasswordForm.new(
      params.require(:reset_password_form).permit(:email)
    )

    invalid_password_reset!(reset_password_form) \
      unless reset_password_form.valid?

    call_service(SendPasswordResetConfirmation,
                 email: reset_password_form.email,
                 success: callback(:password_reset_confirmation_sent),

                 # don't reveal whether or not an account exists
                 not_found: callback(:password_reset_confirmation_sent))
  end

  callback(:password_reset_confirmation_sent) do |email|
    flash[:info] = "We have sent a password reset token to #{email}. (Note " \
                   'that we will only send the email if we have an existing ' \
                   'account associated with that email address.)'
    redirect_to root_path
    halt!
  end

  def verify_reset
    token = params.require(:token)
    call_service(VerifyPasswordResetToken,
                 token: token,
                 success: callback(:password_reset_token_verified),
                 invalid: callback(:password_reset_token_invalid))
  end

  callback(:password_reset_token_verified) do |user|
    flash[:info] = 'Your password reset token has been verified and is now ' \
                   'invalid for future use. Please set a new password for ' \
                   'your account at this time.'
    self.current_user = user
    redirect_to edit_password_path
    halt!
  end

  callback(:password_reset_token_invalid) do
    flash[:error] = 'The password reset token you used is invalid or expired.'
    redirect_to reset_password_path
    halt!
  end

  def edit
    edit_password_form = EditPasswordForm.new
    render locals: { form: edit_password_form }
  end

  def update
    edit_password_form = EditPasswordForm.new(
      params.require(:edit_password_form)
      .permit(:password, :password_confirmation)
    )

    invalid_password_update!(edit_password_form) \
      unless edit_password_form.valid?

    call_service(UpdatePassword,
                 user: current_user,
                 new_password: edit_password_form.password,
                 success: callback(:password_updated))
  end

  callback(:password_updated) do
    flash[:info] = 'Your password has been changed.'
    redirect_to user_path
    halt!
  end

  private

  def invalid_password_reset!(form)
    flash.now[:error] = 'There are errors with your submission. Please ' \
                        'recheck the data you entered.'
    render action: 'reset', locals: { form: form }
    halt!
  end

  def invalid_password_update!(form)
    flash.now[:error] = 'There are errors with your submission. Please ' \
                        'recheck the data you entered.'
    render action: 'edit', locals: { form: form }
    halt!
  end
end
