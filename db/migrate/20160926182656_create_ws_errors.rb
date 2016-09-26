class CreateWsErrors < ActiveRecord::Migration
  def change
    create_table :ws_errors do |t|
      t.string :inspect_model
      t.string :message_error

      t.timestamps null: false
    end
  end
end
