class Concentration < ApplicationRecord
  belongs_to :syllabus

  has_many :concentration_keywords, dependent: :destroy
  has_many :keywords, through: :concentration_keywords
end
