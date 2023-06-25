class AddMatchGroupIdToMatch < ActiveRecord::Migration[6.1]
  def change
    add_reference :matches, :match_group, foreign_key: true
  end
end
