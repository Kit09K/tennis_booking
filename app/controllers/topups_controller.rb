class TopupsController < ApplicationController
  before_action :require_login

  def new
    @topup = Topup.new
  end

  def create
    @topup = Topup.new(topup_params)
    @topup.user_id = session[:user_id]
    @topup.status = 'pending'

    if @topup.save
      redirect_to root_path, notice: "แจ้งเติมเงินสำเร็จ กรุณารอแอดมินอนุมัติ"
    else
      render :new, alert: "เกิดข้อผิดพลาด"
    end
  end

  private

  def require_login
    redirect_to root_path, alert: "กรุณาเข้าสู่ระบบก่อน" unless session[:user_id]
  end

  def topup_params
    params.require(:topup).permit(:amount)
  end
end
