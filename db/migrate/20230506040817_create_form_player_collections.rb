class CreateFormPlayerCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :form_player_collections do |t|

      t.timestamps
    end
  end
end
