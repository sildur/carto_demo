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


FactoryBot.define do
  factory :activity do
    name { Faker::Address.community }
    hours_spent { (rand * 3).round(1) }
    category { %w[cultural nature shopping].sample }
    location { %w[indoors outdoors].sample }
    district { Faker::Address.city }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.latitude }
  end
end
