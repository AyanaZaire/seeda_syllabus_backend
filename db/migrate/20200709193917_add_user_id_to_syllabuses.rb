class AddUserIdToSyllabuses < ActiveRecord::Migration[6.0]
  def change
    add_reference :syllabuses, :user, null: false, foreign_key: true
  end
end
