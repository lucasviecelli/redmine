class ChangeFieldsOfChangeStep < ActiveRecord::Migration
  def change
    remove_column :change_steps, :step_old
    remove_column :change_steps, :step_new
    remove_column :change_steps, :created_at
    remove_column :change_steps, :updated_at
    remove_column :change_steps, :step_table_name
    remove_column :change_steps, :step_attribute
    remove_column :change_steps, :situation
    remove_column :change_steps, :sinc_new

    rename_table :change_steps, :configs

    add_column :configs, :config_name, :string
    add_column :configs, :value, :string
  end
end
