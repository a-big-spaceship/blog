class ApplicationController < ActionController::Base
  before_action :auto_sign_out
  helper_method :current_user

  def logined?
    current_user
  end

  def current_user
    return nil if session[:user_id].blank?

    if @_user_ ||= User.find_by(id: session[:user_id])
      if @_user_&.sign == session[:sign]
        session[:last_visit_at] = Time.now
        cookies.signed[:user_id] = @_user_.id
        @_user_
      else
        reset_session && cookies.delete(:user_id)
        nil
      end
    end
  end

  def user_sign_in(user)
    if user.present?
      reset_session && cookies.delete(:user_id)
      session[:user_id] = user.id
      session[:sign] = user.sign
    end
  end

  def sign_out
    reset_session && cookies.delete(:user_id)
  end

  def auto_sign_out
    if session[:last_visit_at] && session[:last_visit_at] < 2.hours.ago
      reset_session && cookies.delete(:user_id)
      flash[:error] = '已超时，请重新登陆系统！'
      redirect_to "#{new_admin_session_path(redirect_to: request.url)}"
    end
  end

end
