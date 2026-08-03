class SessionsController < ApplicationController
  def create
    auth_info = request.env['omniauth.auth']
    
    render json: auth_info
  end

  def failure
    render plain: "Authentication Failed!"
  end
end