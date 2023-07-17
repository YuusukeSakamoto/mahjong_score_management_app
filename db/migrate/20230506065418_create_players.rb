class CreatePlayers < ActiveRecord::Migration[6.1]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.references :user
      t.string :invite_token, index: { unique: true }
      t.datetime :invite_create_at
      t.timestamps
    end
  end
end
