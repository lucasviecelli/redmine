class CreateDynamicCodes < ActiveRecord::Migration
  def change
    create_table :dynamic_codes do |t|
      t.string :identify
      t.text :code

      t.timestamps null: false
    end
  end
end
