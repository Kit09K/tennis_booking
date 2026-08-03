class User < ApplicationRecord
  has_one :booking, dependent: :destroy
end
