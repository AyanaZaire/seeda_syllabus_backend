class Category < ApplicationRecord
  has_many :syllabuses, dependent: :destroy
end
