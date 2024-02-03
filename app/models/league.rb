# frozen_string_literal: true

class League < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :league_players, dependent: :destroy # leagueに紐づいたleague_playersも削除される
  has_many :match_groups, dependent: :destroy # leagueに紐づいたmatch_groupsも削除される
  has_many :matches, dependent: :destroy # leagueに紐づいたmatchesも削除される
  has_many :share_links, as: :resource, dependent: :destroy # leagueに紐づいたshare_linksも削除される

  validates :name, presence: true, length: { maximum: 15 }
  validates :play_type, presence: true
  validates :rule_id, presence: true
  validates :is_tip_valid, inclusion: [true, false] # boolean型のpresenceチェック

  validates :description, length: { maximum: 50 }

  attr_accessor :mg_ids, :l_match_ids

  # ************************************
  # リーグ情報
  # ************************************
  # リーグにおける最初に記録した日
  def first_record_day
    return nil if matches.count.zero?

    @first_record_day ||= matches.min_by(&:match_on).match_on.to_s(:yeardate)
  end

  # リーグにおける最後に記録した日
  def last_record_day
    return nil if matches.count.zero?

    @last_record_day ||= matches.max_by(&:match_on).match_on.to_s(:yeardate)
  end

  # リーグにおける総対戦数
  def match_count
    @match_count ||= matches.count
  end

  # リーグルールがチップ有かつリーグ成績にチップptを含めるか
  def is_tip_valid?
    Rule.find(rule_id).is_chip && is_tip_valid
  end

  # ************************************
  # リーグ順位表
  # ************************************
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
    rank_num = play_type == 4 ? Result::RANK_NUM : Result::RANK_NUM[0..2]
    rank_num.map do |rank|
      Result.where(player_id: p_id).where(match_id: @l_match_ids).where(rank: rank).count
    end
  end

  # ************************************
  # 総合pt推移グラフ
  # ************************************
  # グラフデータ(各プレイヤーの名前/pt推移/色)を返す
  def graph_data
    graph_datasets = []
    ary = []
    ary << players_name
    ary << point_histories
    ary << player_color
    ary << player_bgcolor
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
    y_max = max.to_i + 100 - (max.to_i % 100) # グラフの最大値を100単位とする
    min = @point_histories.map(&:min).min # グラフの最小値
    y_min = min.to_i - (min.to_i % 100) # グラフの最大値を100単位とする
    [graph_datasets, y_max, y_min]
  end

  # グラフのx軸ラベルを返す
  def graph_label
    mgs = match_groups
    x_label = []
    if is_tip_valid?
      x_label = (1..(matches.count + mgs.count)).to_a #チップ有ルールの場合、チップ分ラベルを追加する
    else
      x_label = (1..(matches.count)).to_a
    end

    if x_label.count >= 20
      x_label.map! do |x|
        if x % 5 == 0
          x  # 5の倍数の場合、そのまま
        else
          ''  # それ以外の場合、空文字列
        end
      end
    elsif x_label.count >= 50
      x_label.map! do |x|
        if x % 10 == 0
          x  # 10の倍数の場合、そのまま
        else
          ''  # それ以外の場合、空文字列
        end
      end
    end
    x_label.unshift('') # グラフの最初のデータは0ptのため、''を先頭に追加する
  end

  # プレイヤー分の成績推移グラフ用のデータを取得する
  def point_histories
    @l_match_ids = matches.pluck(:id)
    @point_histories = []

    # リーグ戦における各playerのptの配列をセットする
    league_players.each do |l_player|
      points = []
      point_history = [0]

      if is_tip_valid?
        # リーグルールがチップ=有かつチップptをリーグ成績に含めるの場合
        mgs = match_groups
        mgs.each do |mg|
          # 対局pt → チップptの順番に配列に格納する
          mg_match_ids = mg.matches.pluck(:id)
          match_tip_pt = Result.where(player_id: l_player.player_id)
                                .where(match_id: mg_match_ids)
                                .pluck(:point)
          match_tip_pt << ChipResult.find_by(player_id: l_player.player_id,
                                              match_group_id: mg.id).point # 該当プレイヤーのチップptを取得
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
  def players_name
    league_players.map { |l_player| l_player.player.name }
  end

  # グラフに表示するプレイヤーの色を返す
  def player_color
    ['#FF4B00', '#005AFF', '#F6AA00', '#52bb93'][0..(play_type - 1)] # 赤,青,オレンジ,緑
  end

  # グラフに表示するプレイヤーの色を返す
  def player_bgcolor
    ['#FFFFFF', '#FFFFFF', '#FFFFFF', '#FFFFFF'][0..(play_type - 1)] # 全部白
  end
end
