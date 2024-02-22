module LoginModule
  def login(user, player)
    visit new_user_session_path
    current_player = user.player
    fill_in 'user_email', with: user.email
    fill_in 'user_password', with: 'password'
    click_button 'ログイン'
  end
end
