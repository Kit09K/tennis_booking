class Admin::TopupsController < ApplicationController
  before_action :require_admin

  def index
    @topups = Topup.includes(:user).order(created_at: :desc)
  end

  def update
    @topup = Topup.find(params[:id])
    if params[:status].in?(%w[approved rejected])
      @topup.update(status: params[:status])
      redirect_to admin_topups_path, notice: "อัปเดตสถานะการเติมเงินสำเร็จ"
    else
      redirect_to admin_topups_path, alert: "ข้อมูลไม่ถูกต้อง"
    end
  end

  private

  def require_admin
    redirect_to root_path, alert: "เฉพาะผู้ดูแลระบบ (Admin) เท่านั้น" unless session[:is_admin]
  end
end
