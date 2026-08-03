class User < ApplicationRecord
  has_many :topups

  def balance
    topups.where(status: "approved").sum(:amount)
  end
  has_many :bookings, dependent: :destroy
  has_one :booking, -> { where.missing(:cancle).order(created_at: :desc) }, class_name: "Booking"
end
