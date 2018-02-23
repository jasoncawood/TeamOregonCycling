class RenameWeightToPositionOnMembershipTypes < ActiveRecord::Migration[5.1]
  def change
    rename_column :membership_types, :weight, :position
  end
end
