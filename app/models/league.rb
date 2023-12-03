class League < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :league_players, dependent: :destroy #leagueに紐づいたleague_playersも削除される
  has_many :match_groups, dependent: :destroy #leagueに紐づいたmatch_groupsも削除される
  has_many :matches, dependent: :destroy #leagueに紐づいたmatchesも削除される
  
  validates :name, presence: true, length: { maximum: 15 }
  validates :play_type, presence: true
  validates :rule_id, presence: true
  
  attr_accessor :mg_ids, :l_match_ids
  
  
  #************************************
  # リーグ情報
  #************************************ 
  # リーグにおける最初に記録した日
  def first_record_day
    return nil if matches.count == 0
    @first_record_day ||= matches.first.match_on.to_s(:yeardate)
  end
  
  # リーグにおける最後に記録した日
  def last_record_day
    return nil if matches.count == 0
    @last_record_day ||= matches.last.match_on.to_s(:yeardate)
  end
  
  # リーグにおける総対局数
  def match_count
    @match_count ||= matches.count
  end
  
  # リーグルールがチップ有か
  def rule_is_tip?
    Rule.find(rule_id).is_chip
  end

  
  #************************************
  # リーグ順位表
  #************************************
  # 順位表データを返す
  def rank_table
    rank_table_data = []
    @l_matches = Match.where(league_id: id)
    @l_match_ids = @l_matches.pluck(:id)
    league_players.each.with_index do |l_player, i|
      data = {}
      data[:name] = l_player.player.name
      data[:total_pt] = @point_histories[i][-1]
      data[:rank_times] = rank_times(l_player.player_id)
      rank_table_data << data
    end
    # 総合ポイントで昇順にする
    rank_table_data.sort_by! { |a| a[:total_pt].to_i }
    rank_table_data.reverse!
  end

  # playerの各順位回数を取得する
  def rank_times(p_id)
    play_type == 4 ? rank_num = Result::RANK_NUM : rank_num = Result::RANK_NUM[0..2]
    rank_num.map do |rank|
      Result.where(player_id: p_id).where(match_id: @l_match_ids).where(rank: rank).count
    end
  end
  #************************************
  # 総合pt推移グラフ
  #************************************
  # グラフデータ(各プレイヤーの名前/pt推移/色)を返す
  def graph_data
    graph_datasets = []
    ary = []
    ary << get_players_name
    ary << get_point_histories
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
    max = @point_histories.map(&:max).max 
    y_max = max.to_i + 100 - (max.to_i % 100) #グラフの最大値を100単位とする
    min = @point_histories.map(&:min).min #グラフの最小値
    y_min = min.to_i - (min.to_i % 100) #グラフの最大値を100単位とする
    return graph_datasets, y_max, y_min
  end
  
  # グラフのx軸ラベルを返す
  def graph_label
    mgs = self.match_groups
    days = matches.pluck(:match_on)
    if rule_is_tip?
      mgs.each do |mg|
        tip_day = mg.matches.last.match_on 
        idx = days.rindex { |day| day == tip_day }
        days.insert(idx, tip_day) # match_group分だけ対局日を追加する(チップpt分レコードが増えるため)
      end
    end
    days.unshift('') #グラフの最初のデータは0ptのため、''を先頭に追加する
    # 同じ日が複数ある場合は最初の日付だけグラフ上に出力するよう配列を編集
    days.map.with_index do |day, i|
      next day if i == 0
      day == days[i - 1] ? '' : day.to_date.to_s(:date)
    end
  end
  
  # プレイヤー分の成績推移グラフ用のデータを取得する
  def get_point_histories
    @l_match_ids = matches.pluck(:id)
    @point_histories = []

    # リーグ戦における各playerのptの配列をセットする
    league_players.each do |l_player|
      points = []
      point_history = [0]
      
      if rule_is_tip?
        # リーグルールがチップ=有の場合
        mgs = self.match_groups
        mgs.each do |mg|
          # 対局pt → チップptの順番に配列に格納する
          mg_match_ids = mg.matches.pluck(:id)
          match_tip_pt = Result.where(player_id: l_player.player_id).where(match_id: mg_match_ids).pluck(:point)
          match_tip_pt << ChipResult.find_by(player_id: l_player.player_id, match_group_id: mg.id).point # 該当プレイヤーのチップptを取得
          points.concat(match_tip_pt) # 配列の各要素を整数として配列に追加する
        end
      else
        # リーグルールがチップ=無の場合
        # 対局ptを配列に格納する
        points = Result.where(player_id: l_player.player_id).where(match_id: @l_match_ids).pluck(:point)
      end
      points.each do |point|
        point_history << (point_history[-1] + point).round(1)
      end
      @point_histories << point_history
    end
    @point_histories
  end
  
  # リーグに属する全プレイヤーの名前を配列で返す
  def get_players_name
    league_players.map{ |l_player| l_player.player.name}
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