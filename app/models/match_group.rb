class MatchGroup < ApplicationRecord
  has_many :matches ,dependent: :destroy #match_groupに紐づいたmatchesも削除される
  belongs_to :rule
  
  # match_group_id単位にすべてのmatchの各プレイヤーのptを配列で取得する
  def points
    match_results = []
    each_points = [] 
    Match.where(match_group_id: id).each do |match|
      match_results << match.results
      each_points << match.results.select(:point).pluck(:point) # match毎の各プレイヤーのptを配列に格納する
    end
    total_points = each_points.transpose.map(&:sum).map { |n| n.round(1) }  
    return match_results, total_points
  end
  
  # match_groupのなかで何個目の要素か(何戦目か)返す
  def get_index(match_id)
    matches.pluck(:id).index(match_id) + 1
  end
  
end
