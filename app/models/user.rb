class User < ApplicationRecord
  has_many :topups

  def balance
    topups.where(status: 'approved').sum(:amount)
  end
end
