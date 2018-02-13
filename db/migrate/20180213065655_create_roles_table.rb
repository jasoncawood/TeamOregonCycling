class CreateRolesTable < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.text :permissions, array: true, default: []
      t.index :name, unique: true
      t.timestamps
    end

    create_join_table :users, :roles do |t|
      t.index [:user_id, :role_id], unique: true
      t.timestamps
    end
  end
end
