class PlayersController < ApplicationController
  before_action :set_player, only: %i[ show edit update destroy ]
  before_action :authenticate_user!

  def show
    @sanyon_match_ids = {} # 三麻/四麻の成績表示のためのハッシュ
    match_ids = Result.where(player_id: params[:id]).pluck(:match_id)
    @sanyon_match_ids[3] = Match.sanma(match_ids).pluck(:id)   #三麻のmatch_idを配列で格納
    @sanyon_match_ids[4] = Match.yonma(match_ids).pluck(:id)   #四麻のmatch_idを配列で格納
  end
  
  def new
    @play_type = params[:play_type]
    @league_name = League.find_by(id: params[:league]).name if params[:league].present?
    # URLによる認証済みプレイヤーがいればセットする
    @authenticated_users = User.where(token_issued_user: current_user.id)
    
    get_played_player
    current_user.generate_authentication_url
    @authentication_url = players_authentications_url(tk: current_user.player_select_token)
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
          redirect_to new_player_path(play_type: p_ids_names.count), alert: "プレイヤー選択でエラーが発生しました" and return
        end
        searched_player.user&.update(token_issued_user: nil) #トークン発行元ユーザーの情報をリセット
        session_players << searched_player
      end
    end
    
    session[:players] = session_players

    # ルール未登録の場合、ルール登録へ遷移
    if current_player.rules.where(play_type: session_players_num).blank?
      redirect_to new_player_rule_path(current_player.id) and return
    else
      LeaguePlayer.create(session[:players], session[:league]) if session[:league].present?
      redirect_to new_match_path(league: session[:league]) and return
    end

  end
  
  private 
  
    def set_player
      @player = Player.find(params[:id])  
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
      names = Player.where(id: p_ids).pluck(:name)
      
      @played_players = p_ids.zip(names) # プレイヤー名とIDを格納

    end
end
