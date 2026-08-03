class CordsController < ApplicationController
  def index
    @cords = Cord.all
    @bookings = Booking.all.map do |b|
      {
        id: b.id,
        cord_id: b.cord_id,
        start_time: b.start_time.iso8601,
        end_time: b.end_time.iso8601,
        date: b.start_time.strftime("%Y-%m-%d"),
        start_hour: b.start_time.hour,
        end_hour: b.end_time.hour
      }
    end
  end

  def temporarily_closed?
    # @current_time = Time.now
    
  end
end
