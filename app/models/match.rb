class Match < ApplicationRecord
  belongs_to :player
  belongs_to :rule
  has_many :results ,dependent: :destroy #matchに紐づいたresultsも削除される
  accepts_nested_attributes_for :results #resultも同時に保存できるようになる
  
  # ★ 追記
  validates :match_day, presence: true
  

  
  # @match.save前にscoreに応じたrankをセットする
  def self.set_rank(match)
    scores = []
    match.results.each_with_index do |result, i|
      scores << [i, result.score]
    end
    
    # scoresにnilが入っている場合、バリデーションエラーとするため以下処理は実行しない
    unless scores.transpose[1].include?(nil)
      #配列の第二要素(result.score)で降順に並び替える
      sorted_scores = scores.sort { |a, b| b[1] <=> a[1] }
      
      rank = 1
      sorted_scores.each do |s|
        match.results[s[0]].rank = rank
        rank += 1
      end
    end
  end
  

  
end
