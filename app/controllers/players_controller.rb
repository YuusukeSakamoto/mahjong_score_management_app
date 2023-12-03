class PlayersController < ApplicationController
  before_action :set_player, only: [:show]
  before_action :authenticate_user!

  def show
    redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless current_player == @player
  end

  def new
    @play_type = params[:play_type]
    end_record if session[:league].present? && session[:mg].nil? # リーグ戦1局目登録中にプレイヤー選択に遷移した場合、セッションを解放する
    if params[:league].present?
      @league = League.find_by(id: params[:league])
      session[:league] = @league.id
      session[:rule] = @league.rule_id
    end
    # URLによる認証済みプレイヤーがいればセットする
    @authenticated_users = User.where(token_issued_user: current_user.id)

    get_played_player
    current_user.generate_authentication_url
    @authentication_url = players_authentications_url(tk: current_user.player_select_token, u_id: current_user.id)
  end

  def create
    session_players = []
    p_ids_names = params[:p_ids].map(&:to_i).zip(params[:p_names])

    p_ids_names.each do |id, name|
      if id == 0
        new_player = Player.create(name: name)
        session_players << new_player
      else
        searched_player = Player.find_by(id: id)
        if searched_player.nil? #playerが登録されていない場合、エラーとする
          get_played_player
          redirect_to new_player_path(play_type: p_ids_names.count), alert: FlashMessages::FAIED_TO_SELECT_PLAYERS and return
        end
        searched_player.user&.update(token_issued_user: nil) #トークン発行元ユーザーの情報をリセット
        session_players << searched_player
      end
    end

    session[:players] = session_players

    # ルール未登録の場合、ルール登録へ遷移
    if current_player.rules.where(play_type: session_players_num).blank?
      redirect_to new_player_rule_path(current_player.id, previous_url: request.referer) and return
    end

    if session[:league].present?
      # リーグ作成後のプレイヤー選択の場合、リーグプレイヤーを登録して対局成績登録へ遷移
      if league_players_registered?
        LeaguePlayer.where(league_id: session[:league]).destroy_all #削除
        LeaguePlayer.create(session[:players], session[:league]) #登録
        redirect_to new_match_path(league: session[:league]) and return
      else
        LeaguePlayer.create(session[:players], session[:league]) # 登録
        redirect_to new_match_path(league: session[:league]) and return
      end
    else
      # 通常対局の場合、対局成績登録へ遷移
      redirect_to new_match_path and return
    end
  end

  private

    def set_player
      @player = Player.find_by(id: params[:id])
      redirect_to root_path, alert: FlashMessages::ACCESS_DENIED and return unless @player
    end

    def get_played_player
      match_ids = Result.where(player_id: current_player.id).pluck(:match_id)
      # current_playerがこれまで遊んだプレイヤーidと記録時間のhashを取得する (最近遊んだ順)
      hash_id_time = Result.where(match_id: match_ids)
                          .where.not(player_id: current_player.id)
                          .group(:player_id)
                          .maximum(:created_at)

      sorted_hash = hash_id_time.sort_by { |_, val| -val.to_i }
      p_ids = sorted_hash.map { |key, _| key } # player_idの配列
      p_names = p_ids.map {|p| Player.find(p).name }

      @played_players = p_ids.zip(p_names) # プレイヤー名とIDを格納
    end

    # リーグプレイヤーがすでに登録されているか
    def league_players_registered?
      l = League.find(session[:league])
      l.league_players.count == l.play_type # リーグプレイヤーが正しい人数登録されている場合true
    end
end
