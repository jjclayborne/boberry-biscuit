class ReworkUsersForAuthentication < ActiveRecord::Migration[8.1]
  def change
    # Users are the studio side of the site: the artist and anyone they let in
    # to edit projects and upload works. Passwords are stored as bcrypt digests
    # by has_secure_password, never in the clear.
    change_table :users, bulk: true do |t|
      t.rename :password, :password_digest
      t.rename :user_type, :role
      t.string :name, null: false, default: ""
    end

    change_column_default :users, :role, "editor"
    User.reset_column_information if defined?(User)

    reversible do |dir|
      dir.up do
        execute "UPDATE users SET role = 'editor' WHERE role IS NULL OR role NOT IN ('admin', 'editor')"
        execute "UPDATE users SET name = split_part(email, '@', 1) WHERE name = ''"
      end
    end

    change_column_null :users, :role, false
    add_index :users, :email, unique: true
  end
end
