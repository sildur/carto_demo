class CreateActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :activities do |t|
      t.string :name
      t.float :hours_spent
      t.string :category
      t.string :location
      t.string :district
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
