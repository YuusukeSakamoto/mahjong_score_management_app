class RenameInviteDigestColumnToPlayers < ActiveRecord::Migration[6.1]
  def change
    remove_column :players, :invite_digest
    add_column :players, :invite_token, :string
  end
end
