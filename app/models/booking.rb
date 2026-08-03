class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :cord
  has_one :cancle

  before_validation :calculate_end, on: :create

  validates :start_time, :end_time, presence: true
  validates :phone, presence: true,
          format: {
            with: /\A0[0-9]{8,9}\z/,
            message: "ต้องเป็นเบอร์โทรศัพท์ที่ถูกต้อง (เช่น 0812345678 หรือ 021234567)"
          }

  validate :no_overlapping_bookings
  validate :no_overlapping_adjustcords

  private

  def calculate_end
    return if start_time.blank?

    self.end_time = start_time + 1.hour
  end


  def no_overlapping_bookings
    return if start_time.blank? || end_time.blank? || cord_id.blank?

    overlapping = Booking.where(cord_id: cord_id)
                         .where.missing(:cancle)
                         .where("start_time < ? AND end_time > ?", end_time, start_time)

    overlapping = overlapping.where.not(id: id) if persisted?

    if overlapping.exists?
      errors.add(:start_time, "ช่วงเวลานี้มีการจองสนามไว้แล้ว กรุณาเลือกช่วงเวลาอื่น")
    end
  end

  def no_overlapping_adjustcords
    return if start_time.blank? || end_time.blank? || cord_id.blank?

    adjusting = Adjustcord.where(cord_id: cord_id)
                          .where("start_date < ? AND end_date > ?", end_time, start_time)

    if adjusting.exists?
      errors.add(:base, "สนามปิดปรับปรุงในช่วงเวลาดังกล่าว ไม่สามารถทำการจองได้")
    end
  end
end
