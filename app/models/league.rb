class League < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :league_players, dependent: :destroy #leagueに紐づいたleague_playersも削除される
  has_many :match_groups, dependent: :destroy #leagueに紐づいたmatch_groupsも削除される
  
  validates :name, presence: true, length: { maximum: 15 }
  validates :play_type, presence: true
  validates :rule_id, presence: true
  
  attr_accessor :mg_ids, :l_match_ids
  
  
  #************************************
  # リーグ情報
  #************************************ 
  # リーグにおける最初に記録した日
  def first_record_day
    return nil if match_groups.count == 0
    @first_record_day ||= match_groups.first.matches.first.match_on.to_s(:yeardate)
  end
  
  # リーグにおける最後に記録した日
  def last_record_day
    return nil if match_groups.count == 0
    @last_record_day ||= match_groups.last.matches.last.match_on.to_s(:yeardate)
  end
  
  # リーグにおける総対局数
  def match_count
    @mg_ids ||= match_groups.pluck(:id)
    @match_count ||= Match.league(@mg_ids).count
  end
  
  #************************************
  # リーグ順位表
  #************************************ 
  # 順位表データを返す
  def rank_table
    rank_table_data = []
    @mg_ids = match_groups.pluck(:id)
    @l_match_ids = Match.league(@mg_ids).pluck(:id) #リーグに紐づくmatch_idを抽出
    league_players.each do |l_player|
      l_player.player.match_ids = @l_match_ids
      data = {}
      data[:name] = l_player.player.name
      data[:total_pt] = l_player.player.total_point_for_league
      data[:rank_times] = l_player.player.rank_times_for_league
      rank_table_data << data
    end
    # 総合ポイントで昇順にする
    rank_table_data.sort_by! { |a| a[:total_pt].to_i }
    rank_table_data.reverse!
  end
  
  #************************************
  # 総合pt推移グラフ
  #************************************ 
  # グラフデータ(各プレイヤーの名前/pt推移/色)を返す
  def graph_data
    graph_datasets = []
    ary = []
    ary << get_players_name
    ary << pt_history
    ary << get_player_color
    ary << get_player_bgcolor
    graph_data = ary.transpose
    graph_data.each do |data|
      data_h = {}
      data_h[:label] = data[0]
      data_h[:data] = data[1]
      data_h[:borderColor] = data[2]
      data_h[:backgroundColor] = data[3]
      graph_datasets << data_h
    end
    max = pt_history.map(&:max).max 
    y_max = max.to_i + 100 - (max.to_i % 100) #グラフの最大値を100単位とする
    min = pt_history.map(&:min).min #グラフの最小値
    y_min = min.to_i - (min.to_i % 100) #グラフの最大値を100単位とする
    return graph_datasets, y_max, y_min
  end
  
  # グラフのx軸ラベルを返す
  def graph_label
    days = Match.league(@mg_ids).pluck(:match_on)
    days.unshift('') #グラフの最初のデータは0ptのため、''を先頭に追加する
    # 同じ日が複数ある場合は最初の日付だけグラフ上に出力するよう配列を編集
    days.map.with_index do |day, i|
      next day if i == 0
      day == days[i - 1] ? '' : day.to_date.to_s(:date)
    end
  end
  
  # リーグに属する全プレイヤーの名前を配列で返す
  def get_players_name
    league_players.map{ |l_player| l_player.player.name}
  end
  
  # 成績推移グラフ用のデータを取得する
  def pt_history
    @points_history = []
    league_players.each do |l_player|
      l_player.player.match_ids = @l_match_ids
      @points_history << l_player.player.point_history_data
    end
    @points_history
  end
  
  # グラフに表示するプレイヤーの色を返す
  def get_player_color
    ["#FF4B00", "#005AFF", "#F6AA00", "#52bb93"][0..(play_type - 1)] # 赤,青,オレンジ,緑
  end
  
  # グラフに表示するプレイヤーの色を返す
  def get_player_bgcolor
    ["#FFFFFF", "#FFFFFF", "#FFFFFF","#FFFFFF"][0..(play_type - 1)] # 全部白
  end
  
end