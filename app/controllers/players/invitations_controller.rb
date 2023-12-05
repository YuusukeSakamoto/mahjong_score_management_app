# frozen_string_literal: true

class Players::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @invited_players = current_player.invitation_players
  end

  def new
    @invited_player = Player.find(params[:player_id])
    @invited_player.create_invite_token # 招待トークンを格納する
    @invite_url = generate_invite_url(@invited_player) # web表示する招待URLを取得する
  end

  private

  # 招待URLを発行する
  def generate_invite_url(invited_player)
    token = invited_player.invite_token.to_s
    p_id = invited_player.id.to_s
    new_user_registration_url(tk: token, p: p_id)
  end
end
