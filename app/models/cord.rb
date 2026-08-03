class Cord < ApplicationRecord
  has_many :bookings, dependent: :destroy
  has_many :adjustcords, dependent: :destroy

  def temporarily_closed?
    
  end
end

