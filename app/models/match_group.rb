class MatchGroup < ApplicationRecord
  has_many :matches ,dependent: :destroy #match_groupに紐づいたmatchesも削除される
  belongs_to :rule
  has_many :chip_results
  belongs_to :league, optional: true #optional:trueで外部キーがnilでもDB登録できる
  
  scope :desc, -> { order(created_at: :desc) } #作成の降順
  
  CHIP = 'tip'
  
  # match_groupに属する対局が何人麻雀か取得する
  def play_type
    matches.first.play_type
  end
  
  # match_group_id単位にすべてのmatchの各プレイヤーのptを配列で取得する
  def get_table_element
    match_results = []
    each_points = [] 
    links = []
    
    Match.where(match_group_id: id).each.with_index(1) do |match, i|
      match_results << match.results
      each_points << match.results.pluck(:point) # match毎の各プレイヤーのptを配列に格納する
      link = {idx: i, id: match.id}
      links << link
    end
    # チップptがあれば追加する
    if chip_results.present? && not_temporary_data?
      chip_points = chip_results.pluck(:point)
      each_points << chip_points
      link = {idx: CHIP} 
      links << link
    end
    total_points = each_points.transpose.map(&:sum).map { |n| n.round(1) }
    return each_points, total_points, links
  end
  
  # match_groupのなかで何個目の要素か(何戦目か)返す
  def get_index(match_id)
    matches.pluck(:id).index(match_id) + 1
  end
  
  # match_groupにおけるプレイヤーを返す
  def players
    Player.where(id: matches.first.results.pluck(:player_id))
  end
  
  private
  
    # チップデータはユーザーによって登録されたデータか(=仮データでないか)
    def not_temporary_data?
      !chip_results.pluck(:is_temporary).all?
    end
  
end
