# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  TOKEN_ENABLED_TIME = 15 # プレイヤー選択におけるトークンの有効期限（分）

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player # ApplicationHelperに記載

  # sessionからmatch_group/rule/league/playersを削除し、match_groupを確定させる
  def end_record
    session[:mg] = nil
    session[:rule] = nil
    session[:league] = nil
    session[:players] = nil
  end

  # flash[:alert]をセットし、ルートパスへリダイレクトする
  def alert_redirect_root(message)
    flash[:alert] = message
    redirect_to(root_path) && return
  end

  unless Rails.env.development?
    rescue_from Exception,                      with: :render_500
    rescue_from ActiveRecord::RecordNotFound,   with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError, params[:path]
  end

  private

  def render_404(error = nil)
    logger.info "Rendering 404 with excaption: #{error.message}" if error

    if request.format.to_sym == :json
      render json: { error: '404 Not Found' }, status: :not_found
    else
      render 'errors/404', status: :not_found, layout: 'error'
    end
  end

  def render_500(error = nil)
    logger.error "Rendering 500 with excaption: #{error.message}" if error

    if request.format.to_sym == :json
      render json: { error: '500 Internal Server Error' }, status: :internal_server_error
    else
      render 'errors/500', status: :internal_server_error, layout: 'error'
    end
  end

  # ユーザー登録時にnameもDB保存する
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name admin_flag avatar])
  end
end
