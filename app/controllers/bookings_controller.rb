class BookingsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  def index
    if current_user.nil?
      redirect_to root_path, alert: "กรุณาเข้าสู่ระบบก่อน"
      return
    end
    
    @bookings = current_user.bookings.order(start_time: :desc)
  end

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
    if start_time <= Time.current
      return render json: { status: "error", errors: ["ไม่สามารถจองช่วงเวลาที่ผ่านไปแล้วได้"] }, status: :unprocessable_entity
    end

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

  def destroy
    if current_user.nil?
      redirect_to root_path, alert: "กรุณาเข้าสู่ระบบก่อน"
      return
    end

    booking = current_user.bookings.find_by(id: params[:id])
    if booking.nil?
      redirect_to bookings_path, alert: "ไม่พบการจองนี้"
      return
    end

    if Cancle.exists?(booking_id: booking.id)
      redirect_to bookings_path, alert: "การจองนี้ถูกยกเลิกไปแล้ว"
      return
    end

    if Time.current >= booking.start_time
      redirect_to bookings_path, alert: "ไม่สามารถยกเลิกการจองที่เลยเวลาเริ่มไปแล้วได้"
      return
    end

    # Calculate refund
    # If cancelled before 60 minutes prior to start_time -> 100% refund (500)
    # If cancelled within 60 minutes of start_time -> 50% refund (250)
    time_diff = booking.start_time - Time.current
    refund_amount = (time_diff > 60.minutes) ? 500 : 250

    Booking.transaction do
      # 1. Create Cancle record
      Cancle.create!(booking_id: booking.id)
      
      # 2. Refund credits
      current_user.topups.create!(amount: refund_amount, status: 'approved')
    end

    redirect_to bookings_path, notice: "ยกเลิกการจองเรียบร้อยแล้ว คุณได้รับเงินคืน #{refund_amount} เครดิต"
  end
end
