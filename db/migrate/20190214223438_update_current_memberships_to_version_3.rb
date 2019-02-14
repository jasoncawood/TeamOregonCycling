class UpdateCurrentMembershipsToVersion3 < ActiveRecord::Migration[5.2]
  def change
    update_view :current_memberships, version: 3, revert_to_version: 2
  end
end
