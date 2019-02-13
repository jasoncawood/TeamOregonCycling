class AddPaymentDataToMemberships < ActiveRecord::Migration[5.2]
  def change
    add_column :memberships, :payment_data, :jsonb, default: {}, null: false
  end
end
