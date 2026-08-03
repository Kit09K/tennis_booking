class CordsController < ApplicationController
  def index
    @cords = Cord.all
    active_bookings = Booking.where.not(id: Cancle.select(:booking_id))
    @bookings = active_bookings.map do |b|
      {
        id: b.id,
        cord_id: b.cord_id,
        start_time: b.start_time.iso8601,
        end_time: b.end_time.iso8601,
        date: b.start_time.strftime("%Y-%m-%d"),
        start_hour: b.start_time.hour,
        end_hour: b.end_time.hour == 0 ? 24 : b.end_time.hour
      }
    end
    @adjustcords = Adjustcord.all.map do |a|
      {
        id: a.id,
        start_date: a.start_date.to_date.to_s,
        end_date: a.end_date.to_date.to_s
      }
    end
  end

  def temporarily_closed?
    # @current_time = Time.now
    
  end
end
