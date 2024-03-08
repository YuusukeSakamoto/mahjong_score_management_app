module PlayerModule
  # プレイヤー選択
  def create_players(players)
    visit new_player_path(play_type: 4)
    find('li', text: players[0].name, visible: :all).click
    find('li', text: players[1].name, visible: :all).click
    element = find('li', text: players[2].name, visible: :all)
    page.execute_script('arguments[0].click();', element.native)
    find('#create_btn', visible: true).click # プレイヤー作成ボタンをクリック
  end
end
