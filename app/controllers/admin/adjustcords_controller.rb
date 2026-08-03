class Admin::AdjustcordsController < ApplicationController
  before_action :require_admin

  def create
    cord = Cord.first # Assuming 1 court as per user's request
    start_date = Date.parse(params[:start_date]).beginning_of_day
    end_date = Date.parse(params[:end_date]).end_of_day

    # 1. Save adjustcord (maintenance period)
    adjustcord = cord.adjustcords.create!(start_date: start_date, end_date: end_date)

    # 2. Cancel bookings within this period and refund 500
    affected_bookings = cord.bookings.where("start_time >= ? AND start_time <= ?", start_date, end_date)
    
    affected_bookings.each do |booking|
      # Refund 500
      booking.user.topups.create!(amount: 500, status: 'approved')
      # Record cancellation (this excludes it from active bookings)
      Cancle.find_or_create_by!(booking_id: booking.id)
    end

    redirect_to root_path, notice: "ตั้งค่าปิดปรับปรุงสนามสำเร็จ และคืนเครดิตให้ลูกค้าที่จองล่วงหน้าในวันนั้นเรียบร้อยแล้ว"
  end

  def destroy
    adjustcord = Adjustcord.find(params[:id])
    adjustcord.destroy
    redirect_to root_path, notice: "ยกเลิกการปิดปรับปรุงสนามแล้ว"
  end

  private

  def require_admin
    redirect_to root_path, alert: "เฉพาะผู้ดูแลระบบเท่านั้น" unless session[:is_admin]
  end
end
