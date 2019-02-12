class UserMailer < ApplicationMailer
  def email_confirmation
    @user = params[:user]
    mail to: @user.email
  end
end
