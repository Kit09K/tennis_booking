class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :cord
  has_one :cancle
end
