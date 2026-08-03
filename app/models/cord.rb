class Cord < ApplicationRecord
  has_many :booking, dependent: :destroy
  has_many :adjustcord, dependent: :destroy

  def temporarily_closed?
    
  end
end

