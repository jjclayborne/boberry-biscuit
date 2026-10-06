class AddStructureToProjects < ActiveRecord::Migration[8.1]
  def change
    # A project is the organizational layer above works: a section of the
    # gallery with one theme or throughline. `section` decides which list it
    # lands in on the portfolio, `kind` is the medium ("photography"), and
    # `commission` stays the client it was made for -- blank for personal work.
    change_table :projects, bulk: true do |t|
      t.string :slug
      t.string :section, null: false, default: "commission"
      t.string :kind
      t.integer :year
      t.integer :position, null: false, default: 0
      t.boolean :published, null: false, default: false
      t.references :user, foreign_key: true
    end

    change_column_null :projects, :commission, true

    reversible do |dir|
      dir.up do
        execute <<~SQL
          UPDATE projects
          SET slug = regexp_replace(lower(name), '[^a-z0-9]+', '-', 'g')
          WHERE slug IS NULL
        SQL
      end
    end

    change_column_null :projects, :slug, false
    add_index :projects, :slug, unique: true
    add_index :projects, [ :section, :position ]
  end
end
