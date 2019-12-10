# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Activity.transaction do
  Activity.destroy_all
  geo_data = JSON.parse(Rails.root.join('db', 'data', 'madrid.json').read)
  geo_data.each do |entry|
    activity = Activity.create!(
      name: entry['name'],
      hours_spent: entry['hours_spent'],
      category: entry['category'],
      location: entry['location'],
      district: entry['district'],
      latitude: entry['latlng'][0],
      longitude: entry['latlng'][1]
    )
    entry['opening_hours'].each do |weekday, hours|
      next unless hours.first.present?

      open_at, close_at = hours.first.split('-')
      activity.opening_hours.create!(
        weekday: weekday,
        open_at: open_at,
        close_at: close_at
      )
    end
  end
end
