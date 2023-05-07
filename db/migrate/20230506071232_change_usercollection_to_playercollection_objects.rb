class ChangeUsercollectionToPlayercollectionObjects < ActiveRecord::Migration[6.1]
  def change
    rename_table :form_user_collections, :form_player_collections
  end
end
