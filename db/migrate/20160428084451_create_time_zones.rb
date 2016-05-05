class CreateTimeZones < ActiveRecord::Migration
  def change
    create_table :time_zones do |t|
      t.string :name
      t.string :value
      t.references :country, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
