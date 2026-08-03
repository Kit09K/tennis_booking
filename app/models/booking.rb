class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :cord
  has_one :cancle

  before_validation :calculate_end, on: :create
  validates :start_time, :end_time, presence: true
  validates :account_number,
            format: { with: /\A\d+\z/, message: "ต้องเป็นตัวเลขเท่านั้น" },
            length: { in: 10..15, message: "ต้องมีความยาวระหว่าง 10 ถึง 15 หลัก" }

  validates :name_account,
            format: { without: /\d/, message: "กรุณาใส่เป็นตัวอักษรเท่านั้น" }

  validates :phone, presence: true,
          format: {
            with: /\A0[0-9]{8,9}\z/,
            message: "ต้องเป็นเบอร์โทรศัพท์ที่ถูกต้อง (เช่น 0812345678 หรือ 021234567)"
          }

  private
  def calculate_end
    nil if start_time.blank?

    self.end_time = start_time + 1.hour
  end
end
