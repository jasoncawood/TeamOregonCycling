class AddTimestampsToMemberships < ActiveRecord::Migration[5.1]
  def change
    change_table :memberships do |t|
      t.datetime :created_at
      t.datetime :updated_at
    end

    execute 'UPDATE memberships SET created_at = CURRENT_TIMESTAMP, updated_at = CURRENT_TIMESTAMP'

    change_column_null :memberships, :created_at, false
    change_column_null :memberships, :updated_at, false
  end
end
