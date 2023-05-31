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
    valid_players = []
    
    # プレイヤー名、IDが空白の場合、配列から削除する
    players.each do |player| 
      next if player.name.blank? & player.id.blank?
      valid_players << player
    end
    
    # 入力されたプレイヤーが２人以下の場合はエラーとする
    if valid_players.count <= 2
      players[0].errors.add(:player, "が不足しています") 
      return false
    end
    
    # byebug
    # IDが重複している場合、エラーとする
    unless player_id_uniq?(valid_players)
      players[0].errors.add(:id, "が重複しています")
      return false
    end
    
    Player.transaction do
      self.players.map do |player|
        
        searched_player = Player.find_by(id: player.id)
        # byebug
        if player.name.blank?
          if player.id.blank?
            next
          elsif player.id.present?
            @session_players << searched_player # 登録済みplayerの場合はplayer情報を取得してsession用配列に格納する
          end
        elsif player.name.present?
          if player.id.blank?
            player.save! # ひとつでもsaveできなければtransactionを抜ける必要があるためsave!
            @session_players << searched_player
          elsif player.id.present?
            @session_players << searched_player
          end
        end
        
        # byebug

      # 2023/5/31時点 ---------------------- start
      # self.players.map do |player|
        
      #   searched_player = Player.find_by(id: player.id)
      #   if searched_player.present?
      #     @session_players << searched_player # 登録済みplayerの場合はplayer情報を取得して配列に格納する
      #     next
      #   else
      #     if player.id == nil #player_idが未入力の場合(=新規登録の場合)
      #       player.save! # ひとつでもsaveできなければtransactionを抜ける必要があるためsave!
      #     elsif player.id != nil && searched_player.present? #player_idが入力有かつ登録済の場合
      #       player.user_id = searched_player.user.id 
      #     else #上記以外（=誤ったIDを入力した場合)
      #       next
      #     end
      #   end
      #   @session_players << player
      # end
      # 2023/5/31時点 ---------------------- end

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
    
    
end