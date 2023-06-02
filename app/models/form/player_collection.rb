class Form::PlayerCollection < Form::Base
  FORM_COUNT = 4 #登録フォームの数を指定
  attr_accessor :players, :input_players

  def initialize(attributes = {})
    super attributes
    self.players = FORM_COUNT.times.map { Player.new() } unless self.players.present?
  end

  def players_attributes=(attributes)
    self.players = attributes.map { |key, value| Player.new(value) }
  end

  def save
    @input_players = []
    Player.transaction do
      self.players.map do |player|
        searched_player = Player.find_by(id: player.id)
        # byebug
        if searched_player.present?
          @input_players << searched_player # 登録済みplayerの場合はplayer情報を取得して配列に格納する
          next
        else
          if player.id == nil #player_idが未入力の場合(=新規登録の場合)
            player.save
          elsif player.id != nil && searched_player.present? #player_idが入力有かつ登録済の場合
            player.user_id = searched_player.user.id 
          else #上記以外（=誤ったIDを入力した場合)
            next
          end
        end
        @input_players << player
        # byebug
      end
    end
      # session[:players] = @input_players
      return true
    rescue => e
      return false
  end
  
end