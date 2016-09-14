class InsertProtocolCustomFieldId < ActiveRecord::Migration
  def change
    Setting.create(name: "protocol_custom_field_id", value: '1')
  end
end
