class Syllabus < ApplicationRecord
  belongs_to :category
  has_many :concentrations, dependent: :destroy

  has_many :keywords, through: :concentrations

  validates :title, presence: true
end
