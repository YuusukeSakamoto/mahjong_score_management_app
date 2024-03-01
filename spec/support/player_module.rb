module PlayerModule
  # プレイヤー選択
  def create_players(players)
  visit new_player_path(play_type: 4)
  find('li', text: players[0].name).click
  find('li', text: players[1].name).click
  find('li', text: players[2].name).click
  find('#create_btn', visible: true).click # プレイヤー作成ボタンをクリック
  end
end
