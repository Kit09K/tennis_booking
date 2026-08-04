class BookingsController < ApplicationController
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
  before_action :authenticate_user!

  def index
    @bookings = current_user.bookings.includes(:cord).order(id: :desc)
  end

  def create
    user = current_user

    # 1. ตรวจสอบยอดเงินคงเหลือ
    if user.balance < 500
      return render_error("Insufficient credit. Please top up at least 500 THB.")
    end

    cord = Cord.find_by(id: booking_params[:cord_id])
    unless cord
      return render_error("Selected court not found.")
    end

    # 2. Parse วันที่และเวลาเริ่มต้น
    begin
      date = Date.parse(booking_params[:date])
    rescue ArgumentError, TypeError
      return render_error("Invalid date format.")
    end

    if date < Date.today
      return render_error("Cannot book for a past date.")
    end

    start_hour = booking_params[:start_hour].to_i
    start_time = Time.zone.local(date.year, date.month, date.day, start_hour, 0, 0)
    end_time   = start_time + 1.hour

    if start_time <= Time.current
      return render_error("Cannot book a time slot that has already passed.")
    end

    # 3. ตรวจสอบว่าผู้ใช้จองซ้ำสำหรับ "สนามนี้" ที่ยังใช้งานอยู่หรือไม่ (จำกัด 1 สิทธิ์ต่อ 1 สนาม)
    cancelled_booking_ids = Cancle.pluck(:booking_id)

    has_active_booking_on_this_court = user.bookings
                                           .where(cord_id: cord.id)
                                           .where("end_time > ?", Time.current)
                                           .where.not(id: cancelled_booking_ids)
                                           .exists?

    if has_active_booking_on_this_court
      return render_error("You already have an active booking for this court (limited to 1 active booking per court).")
    end

    phone = booking_params[:phone]
    if phone.blank?
      return render_error("Please enter your phone number.")
    end

    # 4. บันทึกข้อมูลการจอง
    Booking.transaction do
      @booking = Booking.new(
        user: user,
        cord: cord,
        start_time: start_time,
        end_time: end_time,
        phone: phone
      )

      if @booking.save
        # หักเครดิต 500 บาท
        user.topups.create!(amount: -500, status: "approved")

        respond_to do |format|
          format.html { redirect_to root_path, notice: "Booking successfully created." }
          format.json do
            render json: {
              status: "success",
              message: "Booking created successfully",
              booking: {
                id: @booking.id,
                cord_id: @booking.cord_id,
                date: @booking.start_time.strftime("%Y-%m-%d"),
                start_hour: @booking.start_time.hour,
                end_hour: @booking.end_time.hour == 0 ? 24 : @booking.end_time.hour
              }
            }, status: :created
          end
        end
      else
        render_error(@booking.errors.full_messages)
      end
    end
  end

  def destroy
    booking = current_user.bookings.find_by(id: params[:id])

    if booking.nil?
      redirect_to bookings_path, alert: "Booking not found."
      return
    end

    if Cancle.exists?(booking_id: booking.id)
      redirect_to bookings_path, alert: "This booking has already been cancelled."
      return
    end

    if Time.current >= booking.start_time
      redirect_to bookings_path, alert: "Cannot cancel a booking after its start time has passed."
      return
    end

    # คำนวณเงินคืน
    time_diff = booking.start_time - Time.current
    refund_amount = (time_diff > 60.minutes) ? 500 : 250

    Booking.transaction do
      Cancle.create!(booking_id: booking.id)
      current_user.topups.create!(amount: refund_amount, status: "approved")
    end

    redirect_to root_path, notice: "Booking successfully cancelled. You have received a refund of #{refund_amount} credits."
  end

  private

  def authenticate_user!
    if current_user.nil?
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Please sign in first." }
        format.json { render json: { status: "error", errors: [ "Please sign in before making a booking." ] }, status: :unauthorized }
      end
    end
  end

  def booking_params
    params.require(:booking).permit(:cord_id, :date, :start_hour, :phone)
  end

  def render_error(messages)
    errors = Array(messages)
    respond_to do |format|
      format.html { redirect_to root_path, alert: errors.join(", ") }
      format.json { render json: { status: "error", errors: errors }, status: :unprocessable_entity }
    end
  end
end
