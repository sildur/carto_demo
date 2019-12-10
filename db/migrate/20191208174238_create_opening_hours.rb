class CreateOpeningHours < ActiveRecord::Migration[6.0]
  def change
    create_table :opening_hours do |t|
      t.string :weekday
      t.time :open_at
      t.time :close_at
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
