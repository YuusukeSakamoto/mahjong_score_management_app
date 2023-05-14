class CreateFormResultCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :form_result_collections do |t|

      t.timestamps
    end
  end
end
