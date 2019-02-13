class MembershipsController < ApplicationController
  require_permission :manage_membership, on: :current_user
  skip_before_action :check_membership_status
  before_action :redirect_if_current_member

  def new
    render locals: {
      new_membership: NewMembershipForm.new,
      membership_types: call_service(ListMembershipTypes)
    }
  end

  def payment
    membership = NewMembershipForm.new(
      params
      .require(:new_membership_form)
      .permit(:membership_type_id, :accepts_code_of_conduct)
    )

    return new_membership_form_invalid(membership) unless membership.valid?

    membership_type = call_service(
      GetMembershipType,
      membership_type: membership.membership_type_id
    )

    render locals: {
      membership_type: membership_type,
      paypal_client_id: ENV.fetch('PAYPAL_CLIENT_ID')
    }
  end

  def capture_payment
    call_service(VerifyPayPalPayment,
                 order_id: params.require(:order_id),
                 error: callback(:payment_error),
                 with_result: callback(:payment_success))
  end

  callback(:payment_error) do |message|
    flash[:error] = 'There was an error capturing your payment. Please ' \
                    "<a href=\"#{new_contact_path}\">contact us</a> for " \
                    'assistance. ' + message.to_s
    redirect_to new_membership_path
  end

  callback(:payment_success) do |payment_data|
    call_service(CreateMembershipFromPayment,
                 user: current_user,
                 payment: payment_data,
                 success: callback(:membership_created))
  end

  callback(:membership_created) do |membership|
    flash[:info] = <<~MSG
      Thank you for paying your membership dues. We look forward to seeing you
      at the races!
    MSG
    redirect_to root_path
  end

  private

  def redirect_if_current_member
    if current_user.current_membership.present?
      flash[:warning] = render_to_string(
        partial: 'already_a_member',
        locals: { ends_on: current_user.current_membership.ends_on }
      )
      redirect_to user_path
    end
  end

  def new_membership_form_invalid(membership)
    render action: :new, locals: {
      new_membership: membership,
      membership_types: call_service(ListMembershipTypes)
    }
    halt!
  end
end
