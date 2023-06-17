class ChangeInviteTokenToPlayers < ActiveRecord::Migration[6.1]
  def change
    add_index :players, :invite_token, unique: true
  end
end
