class Player < ApplicationRecord
  validates :name, presence: true
  
  belongs_to :user, optional: true #optional:trueで外部キーがnilでもDB登録できる
  has_many :rules ,dependent: :destroy #playerに紐づいたrulesも削除される
  has_many :matches 
  has_many :results 

  def get_player_name(id)
    Player.find(id).name
  end
  
  def self.get_players_name(results)
    players_name = results.map{ |result| Player.find(result.player_id).name }
    players_name << "-" if results.count == 3
    return players_name
  end
end
