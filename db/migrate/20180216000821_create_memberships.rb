class CreateMemberships < ActiveRecord::Migration[5.1]
  def change
    create_table :memberships do |t|
      t.datetime :starts_on
      t.datetime :ends_on
      t.references :user, foreign_key: true
    end
  end
end
