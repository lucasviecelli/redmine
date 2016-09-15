class AddTableNameToChangeStep < ActiveRecord::Migration
  def change
    add_column :change_steps, :table_name, :string
    add_column :change_steps, :attribute, :string
    remove_column :change_steps, :type
  end
end
