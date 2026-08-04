class Admin::AdjustcordsController < ApplicationController
  before_action :require_admin

  def create
    cord = Cord.first # Assuming 1 court as per user's request
    start_date = Date.parse(params[:start_date]).beginning_of_day
    end_date = Date.parse(params[:end_date]).end_of_day

    if start_date < Date.today.beginning_of_day
      return redirect_to root_path, alert: "ไม่สามารถตั้งค่าปิดปรับปรุงย้อนหลังได้"
    end

    if start_date > end_date
      return redirect_to root_path, alert: "วันที่เริ่มต้นต้องไม่ช้ากว่าวันที่สิ้นสุด"
    end

    # Check for overlap: New period (start_date, end_date) overlaps with an existing period (db_start, db_end)
    # if start_date <= db_end AND end_date >= db_start
    if cord.adjustcords.where("start_date <= ? AND end_date >= ?", end_date, start_date).exists?
      return redirect_to root_path, alert: "ไม่สามารถบันทึกได้ เนื่องจากวันที่เลือกซ้ำซ้อนกับช่วงเวลาที่ปิดปรับปรุงไปแล้ว"
    end

    adjustcord = cord.adjustcords.create!(start_date: start_date, end_date: end_date)

    affected_bookings = cord.bookings.where("start_time >= ? AND start_time <= ?", start_date, end_date)

    affected_bookings.each do |booking|
      # Record cancellation (this excludes it from active bookings)
      c  = Cancle.find_or_create_by!(booking_id: booking.id)
      if c.previously_new_record?
        booking.user.topups.create!(amount: 500, status: "approved")
      end
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
