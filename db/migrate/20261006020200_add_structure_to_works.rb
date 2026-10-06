class AddStructureToWorks < ActiveRecord::Migration[8.1]
  def change
    # `projects_id` came out of the first scaffold pass; every association in
    # the app reads better as `project`.
    rename_column :works, :projects_id, :project_id

    change_table :works, bulk: true do |t|
      t.string :medium
      t.integer :year
      t.integer :position, null: false, default: 0
    end

    add_index :works, [ :project_id, :position ]
  end
end
