class BookingsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def create
    user = current_user
    
    if user.nil?
      return render json: { status: "error", errors: ["กรุณาเข้าสู่ระบบก่อนทำการจอง"] }, status: :unauthorized
    end

    if user.balance < 500
      return render json: { status: "error", errors: ["เครดิตไม่เพียงพอ กรุณาเติมเงินขั้นต่ำ 500 บาท"] }, status: :unprocessable_entity
    end

    cord = Cord.find(params[:cord_id])
    
    # Parse date and start_hour
    date = Date.parse(params[:date])
    if date < Date.today
      return render json: { status: "error", errors: ["ไม่สามารถจองสนามย้อนหลังได้"] }, status: :unprocessable_entity
    end

    start_time = Time.zone.local(date.year, date.month, date.day, params[:start_hour].to_i, 0, 0)
    end_time = start_time + 1.hour
    phone = params[:phone]

    if phone.blank?
      return render json: { status: "error", errors: ["กรุณากรอกเบอร์โทรศัพท์"] }, status: :unprocessable_entity
    end

    Booking.transaction do
      @booking = Booking.new(
        user: user,
        cord: cord,
        start_time: start_time,
        end_time: end_time,
        phone: phone
      )

      if @booking.save
        # Deduct 500 credits
        user.topups.create!(amount: -500, status: 'approved')

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
end
