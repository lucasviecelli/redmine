class CreateChangeSteps < ActiveRecord::Migration
  def change
    create_table :change_steps do |t|
      t.string :type
      t.string :step_old
      t.string :step_new

      t.timestamps null: false
    end
  end
end
