class RenameColumnTableName < ActiveRecord::Migration
  def change
    rename_column :change_steps, :table_name, :step_table_name
    rename_column :change_steps, :attribute, :step_attribute
  end
end
