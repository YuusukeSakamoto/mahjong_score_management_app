# frozen_string_literal: true

class Player < ApplicationRecord
  validates :name, presence: true, length: { maximum: 8 }
  validates :invite_token, uniqueness: true, allow_nil: true

  belongs_to :user, optional: true # optional:trueで外部キーがnilでもDB登録できる
  has_many :rules, dependent: :destroy # playerに紐づいたrulesも削除される
  has_many :matches
  has_many :results
  has_many :leagues

  attr_accessor :invite_token, :match_ids, :cp, :l_points_history

  HYPHEN = ' - '
  HYPHEN_COUNT = 4
  HYPHENS = Array.new(HYPHEN_COUNT, HYPHEN)
  OFTEN_PLAYERS_NUM = 5

  SANMA = 3
  RANK_DATA_NUM = 10 # 順位グラフに表示する数

  # resultsからプレイヤー名を取得する
  def self.find_by_results(results)
    player_ids = results.map(&:player_id)
    player_ids.map do |p_id|
      Player.find(p_id).name
    end
  end

  # ************************************
  # メインデータ
  # ************************************

  # playerの総対戦数を取得する
  def total_match_count(play_type = @play_type)
    @play_type = play_type
    @total_match_count ||= {}
    @total_match_count[play_type] ||= results_for_matches(play_type).count
  end

  # playerが参加したmatchのresultsを取得する
  def results_for_matches(play_type = @play_type)
    @results_for_matches ||= {}
    @results_for_matches[play_type] ||= results.where(match_id: match_ids_for_play_type(play_type))
  end

  # play_typeに基づいて適切なmatch_idsを取得する
  def match_ids_for_play_type(play_type)
    @match_ids = Match.left_joins(:results)
                      .where(play_type: play_type)
                      .where(results: { match_id: Result.match_ids(id) })
                      .distinct
                      .pluck(:id)
  end

  # 直近の対局データを取得する
  def get_sanyon_matches(play_type)
    @sanyon_matches_first_five = {}
    @sanyon_matches_first_five[play_type] = Match.match_ids(match_ids, play_type).desc.first(5)
  end

  # play_typeに基づくmatch_idsを取得する
  def get_sanyon_match_ids(play_type)
    @sanyon_match_ids = {}
    @sanyon_match_ids[play_type] = Match.match_ids(match_ids, play_type)
  end

  # match存在確認
  def matches_present?
    results_for_matches.count.positive?
  end

  # playerの総合ptを取得する
  def total_point(play_type)
    total = results_for_matches(play_type).sum(:point)
    total.zero? ? format('%.1f', total) : format('%+.1f', total)
  end

  # playerの平均順位を取得する
  def average_rank
    return HYPHEN unless matches_present?

    format('%.2f', (results_for_matches.sum(:rank) / total_match_count.to_f))
  end

  # playerの連対率を取得する
  def rentai_rate
    return HYPHEN unless matches_present?

    format('%.2f', ((results_for_matches.where(rank: [1, 2]).count / total_match_count.to_f) * 100))
  end

  # 順位グラフ用データをセットする
  def graph_rank_data(play_type)
    @rank_data = {}
    @rank_data[play_type] = results.where(match_id: get_sanyon_match_ids(play_type)).last(RANK_DATA_NUM).pluck(:rank)
    add_null(@rank_data[play_type]) if @rank_data[play_type].count < RANK_DATA_NUM
    @rank_data
  end

  # RANK_DATA_NUMに満たない場合はNULLで埋める
  def add_null(rank_data)
    (RANK_DATA_NUM - rank_data.count).times do |_i|
      rank_data << nil
    end
  end

  # ************************************
  # 順位別データ
  # ************************************
  # 順位別データを配列にまとめる
  def rank_results(play_type)
    rank_results = [rank_rate, rank_times].transpose
    rank_results.pop if play_type == SANMA # 三麻の場合、4位の結果を消去する
    rank_results
  end

  # playerの各順位率を取得する
  def rank_rate
    return HYPHENS if rank_times.sum.zero?

    rank_times.map do |rank_time|
      format('%.1f', ((rank_time / total_match_count.to_f) * 100))
    end
  end

  # playerの各順位回数を取得する
  def rank_times(play_type = @play_type)
    Result::RANK_NUM.map do |rank|
      results_for_matches(play_type).where(rank: rank).count
    end
  end

  # ************************************
  # 家別データ
  # ************************************
  # 家別データを配列にまとめる
  def ie_results
    [average_rank_by_ie, ie_times, total_point_by_ie].transpose
  end

  # 家別の平均順位を取得する
  def average_rank_by_ie
    ie_times.map.with_index(1) do |ie_time, i|
      next HYPHEN if ie_time.zero?

      format('%.1f', (results_for_matches.where(ie: i).sum(:rank) / ie_time.to_f))
    end
  end

  # 家別の対戦数を取得する
  def ie_times
    Result::IE_NUM.map do |ie|
      results_for_matches.where(ie: ie).count
    end
  end

  # 家別のptを取得する
  def total_point_by_ie
    Result::IE_NUM.map do |ie|
      format('%+.1f', results_for_matches.where(ie: ie).sum(:point))
    end
  end

  # ************************************
  # よく遊ぶプレイヤーデータ
  # ************************************

  # よく遊ぶプレイヤーと回数を取得する（５人まで）
  def often_play_times
    attended_match_ids = results_for_matches.pluck(:match_id)
    often_play_players = Result.where(match_id: attended_match_ids)
                                .where.not(player_id: id)
                                .group(:player_id)
                                .order('count_player_id DESC')
                                .limit(OFTEN_PLAYERS_NUM)
                                .count(:player_id)
                                .to_a

    return often_play_players if often_play_players.count >= OFTEN_PLAYERS_NUM

    # 五人いない場合はハイフンで埋める
    (OFTEN_PLAYERS_NUM - often_play_players.count).times do
      often_play_players << [HYPHEN, 0]
    end
    often_play_players
  end

  # ************************************
  # 最高得点・最低得点
  # ************************************

  # 最高得点を取得する
  def max_score(play_type)
    results_for_matches.maximum(:score)
  end

  # 最高得点のmatch_idを取得する
  def max_score_match_id(play_type)
    results_for_matches.where(score: max_score(play_type)).first.match_id
  end

  # 最高得点の対局日付を取得する
  def max_score_date(play_type)
    Match.find_by(id: max_score_match_id(play_type)).match_on.to_s(:yeardate)
  end

  # 最低得点のレコードを取得する
  def min_score(play_type)
    results_for_matches.minimum(:score)
  end

  # 最低得点のmatch_idを取得する
  def min_score_match_id(play_type)
    results_for_matches.where(score: min_score(play_type)).first.match_id
  end

  # 最低得点の対局日付を取得する
  def min_score_date(play_type)
    return HYPHEN unless matches_present?
    Match.find_by(id: min_score_match_id(play_type)).match_on.to_s(:yeardate)
  end

  # ************************************
  # ユーザー招待リンク用
  # ************************************
  # 招待トークンを発行してDB保存する
  def create_invite_token
    self.invite_token = SecureRandom.urlsafe_base64
    update_columns(invite_token: invite_token, invite_create_at: Time.zone.now)
  end

  # current_playerが招待可能な全プレイヤーを取得する
  def invitation_players
    self.cp = self
    Player.where(id: cp.recorded_players).where(user_id: nil).where(deleted: false)
  end

  # current_playerが記録した対局idを配列で取得
  def recorded_match_ids
    cp.matches.pluck(:id)
  end

  # current_playerが成績記録したプレイヤーを配列で取得
  def recorded_players
    Result.where(match_id: recorded_match_ids).where.not(player_id: cp.id)
          .select(:player_id).distinct.pluck(:player_id)
  end

  # ************************************
  # 登録したルール
  # ************************************

  # 登録した四人麻雀or三人麻雀ルールをすべて取得する
  def rule_list(play_type)
    rules.where(play_type: play_type)
  end

  # ************************************
  # リーグ用メソッド
  # ************************************
  # プレイヤーがリーグ参加しているか
  def leagues_registered?
    LeaguePlayer.exists?(player_id: id)
  end
end
