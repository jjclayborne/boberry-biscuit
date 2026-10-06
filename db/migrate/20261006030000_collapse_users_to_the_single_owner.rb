class CollapseUsersToTheSingleOwner < ActiveRecord::Migration[8.1]
  def change
    # The studio is Nate's alone: there is no one to hand a key to and no one to
    # be an editor instead of an admin, so roles and per-project ownership were
    # recording a distinction that can't exist.
    remove_column :users, :role, :string, default: "editor", null: false
    remove_reference :projects, :user, foreign_key: true, index: true
  end
end
