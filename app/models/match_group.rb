# frozen_string_literal: true

class MatchGroup < ApplicationRecord
  has_many :matches, dependent: :destroy # match_groupに紐づいたmatchesも削除される
  belongs_to :rule
  has_many :chip_results, dependent: :destroy # match_groupに紐づいたchip_resultsも削除される
  has_many :share_links, as: :resource, dependent: :destroy # match_groupに紐づいたshare_linksも削除される
  belongs_to :league, optional: true # optional:trueで外部キーがnilでもDB登録できる

  scope :desc, -> { order(created_at: :desc) } # 作成の降順

  CHIP = 'tip'

  # match_groupに属する対局が何人麻雀か取得する
  def play_type
    matches.first.play_type
  end

  # match_group_id単位にすべてのmatchの各プレイヤーのptを配列で取得する
  def table_element
    match_results = []
    each_points = []

    Match.where(match_group_id: id).each.with_index(1) do |match, _i|
      match_results << match.results
      each_points << match.results.pluck(:point) # match毎の各プレイヤーのptを配列に格納する
    end
    # チップptがあれば追加する
    if chip_results.present? && not_temporary_data?
      chip_points = chip_results.pluck(:point)
      each_points << chip_points
    end
    total_points = each_points.transpose.map(&:sum).map { |n| n.round(1) }
    [each_points, total_points]
  end

  # match_groupのなかで何個目の要素か(何戦目か)返す
  def get_index(match_id)
    matches.pluck(:id).index(match_id) + 1
  end

  # match_groupにおけるプレイヤーを返す
  def players
    Player.where(id: matches.first.results.pluck(:player_id))
  end

  # 作成者かどうか
  def created_by?(current_player)
    return false unless current_player
    matches.first.player_id == current_player.id
  end

  # match_groupに紐づくmatchの数を返す
  def match_count
    matches.count
  end

  # チップ有ルールかどうか
  def chip_rule?
    Rule.find_by(id: rule_id).is_chip?
  end

  # 成績表においてチップレコードかどうか
  def chip_record?(idx)
    chip_rule? && matches.count < idx + 1
  end

  private

  # チップデータはユーザーによって登録されたデータか(=仮データでないか)
  def not_temporary_data?
    !chip_results.pluck(:is_temporary).all?
  end
end
