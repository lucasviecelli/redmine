class AddSituationToChangeStep < ActiveRecord::Migration
  def change
    add_column :change_steps, :situation, :string
  end
end
