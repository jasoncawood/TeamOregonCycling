class AddMembershipTypeIdToMemberships < ActiveRecord::Migration[5.1]
  def change
    change_table :memberships do |t|
      t.references :membership_type, null: false, index: true
    end
  end
end
