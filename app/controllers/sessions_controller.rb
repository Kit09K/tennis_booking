class SessionsController < ApplicationController
  def create
    auth_info = request.env['omniauth.auth']
    
    # บันทึกหรืออัปเดตข้อมูลผู้ใช้ในฐานข้อมูล (users table) โดยยึดตามอีเมล
    user = User.find_or_initialize_by(email: auth_info.info.email)
    user.email = auth_info.info.email
    user.first_name = auth_info.info.first_name
    user.last_name = auth_info.info.last_name
    user.save!
    
    # บันทึกข้อมูลที่จำเป็นลงใน session
    session[:userinfo] = auth_info.info
    session[:uid] = auth_info.uid
    session[:user_id] = user.id
    
    # ตรวจสอบ Admin role จาก Keycloak token (resource_access)
    is_admin = false
    if auth_info.extra && auth_info.extra.raw_info && auth_info.extra.raw_info['resource_access']
      client_access = auth_info.extra.raw_info['resource_access']['tennis-booking-dev']
      is_admin = client_access['roles'].include?('admin') if client_access && client_access['roles']
    end
    session[:is_admin] = is_admin
    
    redirect_to root_path, notice: "เข้าสู่ระบบสำเร็จ"
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "ออกจากระบบแล้ว"
  end

  def failure
    redirect_to root_path, alert: "การเข้าสู่ระบบล้มเหลว!"
  end
end