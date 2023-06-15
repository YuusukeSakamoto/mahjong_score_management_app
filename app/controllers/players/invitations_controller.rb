class Players::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def new
    @invited_player = Player.find(params[:player_id])
    @invited_player.create_invite_token # 招待トークンを格納する
    @invite_url = generate_invite_url(@invited_player) # web表示する招待URLを取得する
  end
  
  private
  
    def generate_invite_url(invited_player)
      "https://09992572d7cb4936a631ba6d42d83668.vfs.cloud9.ap-northeast-1.amazonaws.com/users/sign_up?" +
      "tk=" + 
      invited_player.invite_token.to_s +
      "&p=" +
      invited_player.id.to_s
    end
  
end
