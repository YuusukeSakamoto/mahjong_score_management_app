class AddInvitationToPlayer < ActiveRecord::Migration[6.1]
  def change
    add_column :players, :invite_digest, :string
    add_column :players, :invite_create_at, :datetime
  end
end
