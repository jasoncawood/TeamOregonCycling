class AddLastNameFirstNameToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :last_name, :string, index: true
    add_column :users, :first_name, :string, index: true
    execute "UPDATE users SET last_name='n/a', first_name='n/a'"
    change_column_null :users, :last_name, false
    change_column_null :users, :first_name, false
  end
end
