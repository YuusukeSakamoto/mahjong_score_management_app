class Form::PlayerCollection < Form::Base
  FORM_COUNT = 4 #登録フォームの数を指定
  attr_accessor :players, :session_players

  def initialize(attributes = {})
    super attributes
    self.players = FORM_COUNT.times.map { Player.new() } unless self.players.present?
  end

  def players_attributes=(attributes)
    self.players = attributes.map { |key, value| Player.new(value) }
  end

  def save
    @session_players = []
    player_ids = []
   
    Player.transaction do
      self.players.map do |player|
        
        # IDとプレイヤー名が空白の場合、エラーとする
        if player.id.blank? && player.name.blank?
          player.errors.add(:player, "が不足しています") 
          return false
        end
        
        # IDが重複している場合、エラーとする　
        if player_ids.include?(player.id)
           player.errors.add(:id, "が重複しています")
            return false
        end
        player_ids << player.id
         
        # プレイヤー名のみの場合、プレイヤー新規登録する
        if player.id.blank? && player.name.present?
          player.save! 
          @session_players << player
          next
        end
        
        searched_player = Player.find_by(id: player.id)
        
        # 入力されたIDが未登録の場合、エラーとする
        if searched_player.nil? && player.name.blank?
          player.errors.add(:id, "が未登録です")
          return false
        end
        
        player.user_id = searched_player.user.id if searched_player.user.present? # ユーザー登録しているプレイヤーはuse_idを埋める
        @session_players << searched_player # 登録済みplayerの場合はplayer情報を取得してsession用配列に格納する

      end
      return true
    rescue => e
      return false
    end
  end
  
  private 
    
    # 入力したIDに重複がないか
    def player_id_uniq?(valid_players)
      player_id = valid_players.map(&:id)
      player_id.length == player_id.uniq.length
    end
    
     # 入力されたプレイヤーが4人でない場合はエラーとする
    def is_player_missing?(players, valid_players)
      if valid_players.count != 4
        players[0].errors.add(:player, "が不足しています") 
        return true
      end
    end
    
    # IDが重複している場合、エラーとする
    def is_id_duplicated?(players, valid_players)
      unless player_id_uniq?(valid_players)
        players[0].errors.add(:id, "が重複しています")
        return true
      end
    end
    
end