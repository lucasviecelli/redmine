class InsertUrlWebService < ActiveRecord::Migration
  def change
    Setting.create(name: "url_webservice", value: 'http://localhost:8080/change_protocol')
  end
end
