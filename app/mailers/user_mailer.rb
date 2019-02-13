class UserMailer < ApplicationMailer
  add_template_helper(ApplicationHelper)

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
end
