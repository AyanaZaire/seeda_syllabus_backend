class AddCategoryToSyllabus < ActiveRecord::Migration[6.0]
  def change
    add_reference :syllabuses, :category, foreign_key: true
  end
end
