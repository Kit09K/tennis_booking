class BookingsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def create
    user = current_user
    cord = Cord.find(params[:cord_id])
    start_time = Time.parse(params[:start_time])
    end_time = Time.parse(params[:end_time])

    @booking = Booking.new(
      user: user,
      cord: cord,
      start_time: start_time,
      end_time: end_time,
    )

    if @booking.save
      render json: {
        status: "success",
        message: "Booking created successfully",
        booking: {
          id: @booking.id,
          cord_id: @booking.cord_id,
          date: @booking.start_time.strftime("%Y-%m-%d"),
          start_hour: @booking.start_time.hour,
          end_hour: @booking.end_time.hour
        }
      }, status: :created
    else
      render json: {
        status: "error",
        errors: @booking.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
