class AddApprovalRequiredToMembershipTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :membership_types, :approval_required, :boolean, default: false,
      null: false
  end
end
