class RemoveUniqueConstraintFromMembershipTypePosition < ActiveRecord::Migration[5.1]
  def up
    remove_index :membership_types, :position
    add_index :membership_types, :position
  end

  def down
    remove_index :membership_types, :position
    add_index :membership_types, :position, unique: true
  end
end
