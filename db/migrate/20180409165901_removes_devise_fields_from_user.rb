class RemovesDeviseFieldsFromUser < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :memberships, :users
    rename_table :users, :_old_users
    change_table :_old_users do |t|
      t.index :email, unique: true, name: '_old_users_email_uniq_idx'
    end

    create_table :users do |t|
      t.string :email, null: false
      t.index :email, unique: true
      t.string :last_name, index: true, null: false
      t.string :first_name, index: true, null: false
      t.string :password_digest, null: false
      t.string :confirmation_token
      t.timestamp :confirmed_at
      t.string :unconfirmed_email
      t.timestamp :discarded_at
      t.timestamps
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          INSERT INTO users (email, last_name, first_name, password_digest,
                             confirmation_token, confirmed_at,
                             unconfirmed_email, created_at, updated_at,
                             discarded_at)
            SELECT email, last_name, first_name, encrypted_password,
                   confirmation_token, confirmed_at, unconfirmed_email,
                   created_at, updated_at, discarded_at
              FROM _old_users;
          SQL
      end

      dir.down do
        execute <<~SQL.squish
          INSERT INTO _old_users (email, last_name, first_name,
                                  encrypted_password, confirmation_token,
                                  confirmed_at, unconfirmed_email, created_at,
                                  updated_at, discarded_at)
            SELECT email, last_name, first_name, password_digest,
                   confirmation_token, confirmed_at, unconfirmed_email,
                   created_at, updated_at, discarded_at
              FROM users
            ON CONFLICT (email)
              DO UPDATE SET last_name = EXCLUDED.last_name,
                            first_name = EXCLUDED.first_name,
                            encrypted_password = EXCLUDED.encrypted_password,
                            confirmation_token = EXCLUDED.confirmation_token,
                            confirmed_at = EXCLUDED.confirmed_at,
                            unconfirmed_email = EXCLUDED.unconfirmed_email,
                            created_at = EXCLUDED.created_at,
                            updated_at = EXCLUDED.updated_at,
                            discarded_at = EXCLUDED.discarded_at;
          SQL
      end
    end

    add_foreign_key :memberships, :users
  end
end
