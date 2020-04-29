class RemoveCategoryIdFromSyllabusesTable < ActiveRecord::Migration[6.0]
  def change
    remove_column :syllabuses, :category_id, :string
  end
end
