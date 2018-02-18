class AddAmountPaidToMemberships < ActiveRecord::Migration[5.1]
  def change
    add_monetize :memberships, :amount_paid
  end
end
