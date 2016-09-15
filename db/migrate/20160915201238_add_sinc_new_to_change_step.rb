class AddSincNewToChangeStep < ActiveRecord::Migration
  def change
    add_column :change_steps, :sinc_new, :boolean
  end
end
