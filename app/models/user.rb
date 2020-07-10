class User < ApplicationRecord
  has_secure_password

  has_many :syllabuses, dependent: :destroy

  validates :email, uniqueness: { case_sensitive: false }
end
