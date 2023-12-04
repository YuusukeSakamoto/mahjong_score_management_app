# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  INVITATIOM_TOKEN_ENABLED_TIME = 12 #招待トークン有効時間
  # GET /resource/sign_up
  def new
    super and return unless params_exist?
    unless invitaion_valid?
      redirect_to root_path ,alert: FlashMessages::INVALID_LINK and return
    end
    @invited_player = Player.find(params[:p])
    super
  end

  # POST /resource
  def create
    # super
    # devise元コードから転記---ここから---------------------------------
    build_resource(sign_up_params)
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        # 招待されたプレイヤーがユーザー登録した場合
        if params[:p_id].present?
          save_user_id_to_invited_player
        else
          @user.build_player(name: @user.name)
          @user.save
        end
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
    # devise元コードから転記----ここまで-------------------------------

  end

  # GET /resource/edit
  def edit
    super
  end

  # PUT /resource
  def update
    super
    @player = @user.player
    @player.name = @user.name
    @player.save
  end

  # DELETE /resource
  def destroy
    # super
    # devise元コードから転記---ここから---------------------------------
    if resource.valid_password?(params[:current_password]) # パスワードが一致している場合
      resource.destroy
      # 追加開始 
      resource.player.name = "削除済プレイヤー" 
      resource.player.user_id = nil
      resource.player.save
      # 追加終了
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      set_flash_message! :notice, :destroyed
      yield resource if block_given?
      respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name), status: Devise.responder.redirect_status }
    else
      @user = resource
      @user.errors.add(:current_password, 'が違います')
      render template: "unsubscribes/index"
    end
    # devise元コードから転記----ここまで-------------------------------
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    super
  end

  protected
  
  def params_exist?
    params[:tk].present? && params[:p].present?
  end
  
  # 招待トークンが正しいかつ期限切れでない場合にtrueを返す
  def invitaion_valid?
    invited_player = Player.find_by(id: params[:p])
    return false if invited_player.nil?
    Player.find_by(invite_token: params[:tk]) == invited_player && 
    invited_player.invite_create_at > INVITATIOM_TOKEN_ENABLED_TIME.hours.ago
  end
  
  # 招待されたplayerに新規登録したuser_idを保存する
  def save_user_id_to_invited_player
    player = Player.find(params[:p_id])
    player.update_columns(name: params[:user][:name] ,user_id: @user.id)
  end
  

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    super(resource)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    super(resource)
  end
end
