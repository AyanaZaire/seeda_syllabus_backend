class CreateConcentrations < ActiveRecord::Migration[6.0]
  def change
    create_table :concentrations do |t|
      t.string :title
      t.string :description
      t.references :syllabus, null: false, foreign_key: true

      t.timestamps
    end
  end
end
