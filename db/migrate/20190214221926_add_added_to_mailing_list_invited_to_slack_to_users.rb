class AddAddedToMailingListInvitedToSlackToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :added_to_mailing_list, :boolean, default: false,
               null: false, index: true
    add_column :users, :invited_to_slack, :boolean, default: false,
               null: false, index: true
  end
end
