class Cord < ApplicationRecord
  has_many :booking, dependent: :destroy
  has_many :adjustcord, dependent: :destroy
end
