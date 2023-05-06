class CreateFormBases < ActiveRecord::Migration[6.1]
  def change
    create_table :form_bases do |t|

      t.timestamps
    end
  end
end
