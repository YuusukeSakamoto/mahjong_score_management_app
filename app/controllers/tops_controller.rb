class TopsController < ApplicationController
  
  RANK_DATA_NUM = 10 #順位グラフに表示する数
  
  def show
    if user_signed_in?
      @match_group = set_session_match_group if recording?
      @player = Player.find_by(user_id: current_user.id)
      match_ids = Result.match_ids(current_player.id)
      set_sanyon_matches(match_ids)
      set_sanyon_match_ids(match_ids)
      set_graph_rank_data
    end
  end
  
  private
  
    def set_sanyon_matches(match_ids)
      @sanyon_matches = {}
      @sanyon_matches[3] = Match.sanma(match_ids).desc.first(5)
      @sanyon_matches[4] = Match.yonma(match_ids).desc.first(5)
    end
    
    def set_sanyon_match_ids(match_ids)
      @sanyon_match_ids = {}
      @sanyon_match_ids[3] = Match.sanma(match_ids) #三麻のmatch_idを配列で格納
      @sanyon_match_ids[4] = Match.yonma(match_ids) #四麻のmatch_idを配列で格納
    end
    
    # 順位グラフ用データをセットする
    def set_graph_rank_data
      @rank_data = {}
      @rank_data[3] = @player.results.where(match_id: @sanyon_match_ids[3]).last(RANK_DATA_NUM).pluck(:rank)
      add_null(@rank_data[3]) if @rank_data[3].count <= RANK_DATA_NUM
      @rank_data[4] = @player.results.where(match_id: @sanyon_match_ids[4]).last(RANK_DATA_NUM).pluck(:rank)
      add_null(@rank_data[4]) if @rank_data[4].count <= RANK_DATA_NUM
    end
    
    # RANK_DATA_NUMに満たない場合はNULLで埋める
    def add_null(rank_data)
      (RANK_DATA_NUM - rank_data.count).times do |i|
        rank_data << nil
      end
    end
end
