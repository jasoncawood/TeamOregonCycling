class CreateCurrentMemberships < ActiveRecord::Migration[5.1]
  def change
    create_view :current_memberships
  end
end
