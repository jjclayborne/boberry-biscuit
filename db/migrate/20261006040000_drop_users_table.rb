class DropUsersTable < ActiveRecord::Migration[8.1]
  def change
    # Who may sign in is now a roster in encrypted credentials, and an account
    # is only a credential -- there is no per-account data, so there is nothing
    # left for this table to hold. Dropping it also makes it structurally
    # impossible for a second gallery to appear behind a second email.
    drop_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :name, default: "", null: false
      t.timestamps
      t.index [ :email ], unique: true
    end
  end
end
