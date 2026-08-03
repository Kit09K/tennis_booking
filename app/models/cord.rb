class Cord < ApplicationRecord
  has_many :booking, dependent: :destroy
end
