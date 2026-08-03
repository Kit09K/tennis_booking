class SessionsController < ApplicationController
  def create
    auth_info = request.env["omniauth.auth"]
    puts "AUTH #{auth_info}"
    session[:id_token] = auth_info.extra["id_token"]

    user = User.find_or_initialize_by(email: auth_info.info.email)
    user.email = auth_info.info.email
    user.first_name = auth_info.info.first_name
    user.last_name = auth_info.info.last_name
    user.save!

    session[:userinfo] = auth_info.info
    session[:uid] = auth_info.uid
    session[:user_id] = user.id

    is_admin = false
    if auth_info.extra && auth_info.extra.raw_info && auth_info.extra.raw_info["resource_access"]
      client_access = auth_info.extra.raw_info["resource_access"]["tennis-booking-dev"]
      is_admin = client_access["roles"].include?("admin-tennis") if client_access && client_access["roles"]
    end
    session[:is_admin] = is_admin

    redirect_to root_path, notice: "เข้าสู่ระบบสำเร็จ"
  end

  def destroy
      id_token = session[:id_token]

      reset_session

      client_id = ENV.fetch("KEYCLOAK_CLIENT_ID", "")
      keycloak_base_logout_url = "https://sso-dev.odd.works/realms/exam-internship/protocol/openid-connect/logout"

      params = {
        client_id: client_id,
        post_logout_redirect_uri: "#{request.base_url}/"
      }

      params[:id_token_hint] = id_token if id_token.present?

      logout_uri = URI.parse(keycloak_base_logout_url)
      logout_uri.query = params.to_query

      redirect_to logout_uri.to_s, allow_other_host: true
  end

  def failure
    redirect_to root_path, alert: "การเข้าสู่ระบบล้มเหลว!"
  end
end
