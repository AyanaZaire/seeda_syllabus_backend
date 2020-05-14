class AddCategoryToSyllabus < ActiveRecord::Migration[6.0]
  def change
    add_reference :syllabuses, :category, null: false, foreign_key: true
  end
end
