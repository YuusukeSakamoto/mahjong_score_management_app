# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationHelper

  CONTACT_FORM_URL = 'https://docs.google.com/forms/d/e/1FAIpQLSfaU5E9ZRDLx2micWsqHWaA2ghyoIyGucjKQ7MN7rbvgMl1pA/viewform' # お問い合わせフォームURL
  TOKEN_ENABLED_TIME = 10 # プレイヤー選択におけるトークンの有効期限（分）

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :current_player # ApplicationHelperに記載

  helper_method :contact_form_url

  # お問い合わせフォームURLを返す
  def contact_form_url
    CONTACT_FORM_URL
  end

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

  # URLに含まれる共有トークンが正しいか検証する
  def validate_share_token(tk, resource_type, controller, instance)
    share_token = ShareLink.find_by(token: params[:tk], resource_type: params[:resource_type])

    unless share_token
      redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
      return
    end

    case params[:resource_type]
      when 'MatchGroup'
        case controller
          when 'match_groups_controller'
            unless instance == MatchGroup.find_by(id: share_token.resource_id)
              redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
              return
            end
          when 'matches_controller'
            mg_by_token = MatchGroup.find_by(id: share_token.resource_id)
            unless mg_by_token.matches.include?(instance)
              redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
              return false
            end
          when 'chip_results_controller'
            unless instance == MatchGroup.find_by(id: share_token.resource_id)
              redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
              return false
            end
          when 'leagues_controller'
            unless instance.match_groups.include?(MatchGroup.find_by(id: share_token.resource_id))
              redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
              return false
            end
        end
        when 'League'
          case controller
            when 'match_groups_controller'
              league = League.find_by(id: share_token.resource_id)
              unless league.match_groups.include?(instance)
                redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
                return
              end
            when 'matches_controller'
              league = League.find_by(id: share_token.resource_id)
              mg = MatchGroup.find_by(id: instance.match_group_id)
              unless league.match_groups.include?(mg)
                redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
                return false
              end
            when 'chip_results_controller'
              league = League.find_by(id: share_token.resource_id)
              unless league.match_groups.include?(instance)
                redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
                return false
              end
            when 'leagues_controller'
              league_by_token = League.find_by(id: share_token.resource_id)
              unless instance == league_by_token
                redirect_to(root_path, alert: FlashMessages::INVALID_LINK)
                return false
              end
          end
      end
    return share_token
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
