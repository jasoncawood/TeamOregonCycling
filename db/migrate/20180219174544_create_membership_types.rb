class CreateMembershipTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :membership_types do |t|
      t.string :name, null: false
      t.integer :weight, null: false
      t.string :description, null: false
      t.monetize :price, null: false
      t.datetime :discarded_at
      t.timestamps
      t.index :name, unique: true
      t.index :weight, unique: true
      t.index :discarded_at
    end
  end
end
