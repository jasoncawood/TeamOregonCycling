class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

  class << self
    def send_password_reset_confirmation(**params)
      with(**params)
        .password_reset_confirmation
        .deliver_now
    end
  end

  def email_confirmation
    @user = params[:user]
    mail subject: 'Email Confirmation Required',
         to: @user.email
  end

  def membership_purchased
    @user = params[:user]
    @membership = params[:membership]
    mail to: 'info@teamoregon.org',
         subject: 'Membership Purchased/Renewed'
  end

  def password_reset_confirmation
    @user = params[:user]
    mail subject: 'Password Reset Requested',
         to: @user.email
  end
end
