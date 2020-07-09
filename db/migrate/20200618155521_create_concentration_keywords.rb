class CreateConcentrationKeywords < ActiveRecord::Migration[6.0]
  def change
    create_table :concentration_keywords do |t|
      t.references :concentration, null: false, foreign_key: true
      t.references :keyword, null: false, foreign_key: true

      t.timestamps
    end
  end
end
