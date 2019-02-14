class CreateMembershipFromPayment < ApplicationService
  input :user
  input :payment
  input :success

  require_permission :purchase_membership, on: :user

  main do
    load_user
    extract_membership_purchase
    load_membership_type
    determine_starts_on
    determine_ends_on
    create_membership
    notify_admins
    run_callback(success, membership)
  end

  private

  attr_accessor :membership_purchase, :starts_on, :ends_on, :membership_type,
                :membership

  def extract_membership_purchase
    data = items.detect { |item|
      MembershipType.sku_matches?(item.sku)
    }

    raise 'No membership appears to have been purchased!' if data.nil?

    self.membership_purchase = MembershipPurchase.new(data)
  end

  def items
    payment&.purchase_units&.first&.items
  end

  def determine_starts_on
    self.starts_on = [current_membership&.ends_on, Date.today]
                     .compact
                     .max
                     .at_midnight
  end

  def determine_ends_on
    self.ends_on = (starts_on + 1.year).at_midnight
  end

  def current_membership
    user.current_membership
  end

  def load_user
    call_service(GetUser, user: user, with_result: callback(:user=))
  end

  def load_membership_type
    call_service(
      GetMembershipType,
      membership_type: membership_purchase.membership_type_id,
      with_result: callback(:membership_type=)
    )
  end

  def create_membership
    self.membership = Membership.create!(
      user: user,
      membership_type: membership_type,
      starts_on: starts_on,
      ends_on: ends_on,
      amount_paid: membership_purchase.amount_paid,
      payment_data: PayPalClient.openstruct_to_hash(payment)
    )
  end

  def notify_admins
    UserMailer
      .with(user: user, membership: membership)
      .membership_purchased
      .deliver_now
  end

  class MembershipPurchase
    attr_accessor :membership_type_id, :amount_paid

    def initialize(data)
      self.membership_type_id = data.sku.split(MembershipType::SKU_SEP).last
      self.amount_paid = data.unit_amount.value
    end
  end
end
