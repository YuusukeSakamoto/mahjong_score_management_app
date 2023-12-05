class CreateFormBases < ActiveRecord::Migration[6.1]
  def change
    create_table :form_bases, &:timestamps
  end
end
