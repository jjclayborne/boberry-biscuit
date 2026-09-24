class CreateWorks < ActiveRecord::Migration[8.1]
  def change
    create_table :works do |t|
      t.string :name, null: false
      t.string :blurb
      t.references :projects, foreign_key: true, null: false
      t.timestamps
    end
  end
end
