# frozen_string_literal: true

# == Schema Information
#
# Table name: activities
#
#  id          :integer          not null, primary key
#  name        :string
#  hours_spent :float
#  category    :string
#  location    :string
#  district    :string
#  latitude    :float
#  longitude   :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Activity < ApplicationRecord
  has_many :opening_hours, dependent: :destroy

  validates :name, :hours_spent, :category, :location, :district, :latitude,
            :longitude, presence: true

  def as_json(_options = nil)
    {
      'type' => 'Feature',
      'geometry' => {
        'type' => 'Point',
        'coordinates' => [longitude, latitude]
      },
      'properties' => {
        'name' => name,
        'hours_spent' => hours_spent,
        'category' => category,
        'location' => location,
        'district' => district
      }
    }
  end

  def self.as_geojson(results)
    { type: 'FeatureCollection', features: results }
  end

  def self.recommended(category:, start_at:, end_at:, weekday:)
    start_hour, start_minute = start_at.split(':')
    end_hour, end_minute = end_at.split(':')

    Activity.where(
      category: category
    ).joins(:opening_hours).where(
      'opening_hours.open_at <= :start_at ' \
        "AND DATETIME(:start_at, '+' || hours_spent || ' hour') <= opening_hours.close_at " \
        "AND DATETIME(:start_at, '+' || hours_spent || ' hour') <= :end_at " \
    'AND opening_hours.weekday = :weekday',
      start_at: Time.utc(2000, 1, 1, start_hour, start_minute),
      end_at: Time.utc(2000, 1, 1, end_hour, end_minute),
      weekday: weekday
    ).order(
      Arel.sql('hours_spent DESC')
    ).limit(1)
  end
end
