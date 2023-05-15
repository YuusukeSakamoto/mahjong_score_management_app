class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :results ,dependent: :destroy #matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results #resultも同時に保存できるようになる
  
  def self.set_rank(match)
    scores = []
    match.results.each_with_index do |result, i|
      scores << [i, result.score]
    end
    
    #配列の第二要素(result.score)で降順に並び替える
    sorted_scores = scores.sort { |a, b| b[1] <=> a[1] }
    
    rank = 1
    sorted_scores.each do |s|
      match.results[s[0]].rank = rank
      rank += 1
    end
  end
end
