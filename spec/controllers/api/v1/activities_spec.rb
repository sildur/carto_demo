# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::ActivitiesController do
  def to_geojson(activity)
    {
      'type' => 'Activity',
      'geometry' => {
        'type' => 'Point',
        'coordinates' =>
          [activity.longitude, activity.latitude]
      },
      'properties' => {
        'name' => activity.name,
        'hours_spent' => activity.hours_spent,
        'category' => activity.category,
        'location' => activity.location,
        'district' => activity.district
      }
    }
  end

  describe 'GET #index' do
    describe 'with no parameters' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
      it 'returns a GeoJSON with all the activities' do
        activities = create_list(:activity, 10)
        get :index
        response_data = JSON.parse(response.body)
        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to match_array(activities.collect(&:as_json))
      end
    end
    describe 'with a category parameter' do
      it 'returns http success' do
        get :index, params: { category: 'shopping' }
        expect(response).to have_http_status(:success)
      end
      it 'returns a GeoJSON with the activities filtered by category' do
        create_list(:activity, 5, category: 'shopping')
        create_list(:activity, 5, category: 'cultural')
        get :index, params: { category: 'shopping' }
        response_data = JSON.parse(response.body)
        expect(response_data['features'].size).to eq(5)
        retrieved_categories = response_data['features'].collect do |entry|
          entry.dig('properties', 'category')
        end.uniq
        expect(retrieved_categories).to eq(['shopping'])
      end
    end
    describe 'with a pair of latitude/longitude parameters' do
      it 'returns http success' do
        get :index, params: { latitude: 1, longitude: 1 }
        expect(response).to have_http_status(:success)
      end
      it 'returns a GeoJSON with the activities filtered by category' do
        create_list(:activity, 5, latitude: 1, longitude: 2)
        create_list(:activity, 5, latitude: 3, longitude: 4)
        get :index, params: { latitude: 1, longitude: 2 }
        response_data = JSON.parse(response.body)
        expect(response_data['features'].size).to eq(5)
        retrieved_locations = response_data['features'].collect do |entry|
          [entry.dig('geometry', 'coordinates')]
        end.uniq
        expect(retrieved_locations).to eq([[[2.0, 1.0]]])
      end
    end
  end

  describe 'GET #recommended' do
    describe 'with no category' do
      before do
        get :recommended, params: {
          start_at: '10:00', end_at: '11:00',
          weekday: 'mo'
        }
      end
      it 'returns http error' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'requires a category parameter' do
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to eq(['category is required'])
      end
    end
    describe 'with no weekday' do
      before do
        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '11:00',
        }
      end
      it 'returns http error' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'requires a weekday parameter' do
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to eq(['weekday is required'])
      end
    end
    describe 'with no time range' do
      before do
        get :recommended, params: {
          category: 'shopping', weekday: 'mo'
        }
      end
      it 'returns http error' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'requires start_at and end_at parameters' do
        response_data = JSON.parse(response.body)
        expect(response_data['errors']).to match_array(
          ['start_at is required', 'end_at is required']
        )
      end
    end

    describe 'with an invalid start_at' do
      before do
        get :recommended, params: {
          category: 'shopping', start_at: '1000', end_at: '12:00',
          weekday: 'mo'
        }
      end
      it 'returns http error' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'requires start_at to have a valid format' do
        response_data = JSON.parse(response.body)
        expect(
          response_data['errors']
        ).to eq(['start_at has an invalid format'])
      end
    end

    describe 'with an invalid end_at' do
      before do
        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '1200',
          weekday: 'mo'
        }
      end
      it 'returns http error' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'requires start_at to have a valid format' do
        response_data = JSON.parse(response.body)
        expect(
          response_data['errors']
        ).to eq(['end_at has an invalid format'])
      end
    end

    describe 'with a category and a time range' do
      it 'returns http success' do
        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '11:00',
          weekday: 'mo'
        }
        expect(response).to have_http_status(:success)
      end
      it 'returns a single activity and all its details, in GeoJSON format' do
        activity_a = create(
          :activity,
          category: 'shopping',
          hours_spent: 1,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '11:00', weekday: 'mo'
          )]
        )
        activity_b = create(
          :activity,
          category: 'shopping',
          hours_spent: 1,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '11:00', weekday: 'su'
          )]
        )

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '11:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_a)])

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '11:00',
          weekday: 'su'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_b)])
      end
      it 'returns a activity belonging to the category' do
        activity_a = create(
          :activity,
          category: 'shopping',
          hours_spent: 1,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '11:00', weekday: 'mo'
          )]
        )
        activity_b = create(
          :activity,
          category: 'cultural',
          hours_spent: 1,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '11:00', weekday: 'mo'
          )]
        )

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '11:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_a)])

        get :recommended, params: {
          category: 'cultural', start_at: '10:00', end_at: '11:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_b)])
      end
      it 'returns a activity open during the time of visit' do
        activity_a = create(
          :activity,
          category: 'shopping',
          hours_spent: 1.5,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '13:00', weekday: 'mo'
          )]
        )
        activity_b = create(
          :activity,
          category: 'shopping',
          hours_spent: 1.5,
          opening_hours: [create(
            :opening_hour, open_at: '15:00', close_at: '20:00', weekday: 'mo'
          )]
        )

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '13:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_a)])

        get :recommended, params: {
          category: 'shopping', start_at: '15:00', end_at: '20:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_b)])
      end
      it 'returns a activity open during the time of visit including staying time' do
        activity_a = create(
          :activity,
          category: 'shopping',
          hours_spent: 2,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '20:00', weekday: 'mo'
          )]
        )
        activity_b = create(
          :activity,
          category: 'shopping',
          hours_spent: 5,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '20:00', weekday: 'mo'
          )]
        )

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '12:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_a)])

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '15:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_b)])
      end
      it 'returns the activity with the longest visit time' do
        activity_a = create(
          :activity,
          category: 'shopping',
          hours_spent: 5,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '20:00', weekday: 'mo'
          )]
        )
        create(
          :activity,
          category: 'shopping',
          hours_spent: 2,
          opening_hours: [create(
            :opening_hour, open_at: '10:00', close_at: '20:00', weekday: 'mo'
          )]
        )

        get :recommended, params: {
          category: 'shopping', start_at: '10:00', end_at: '15:00',
          weekday: 'mo'
        }
        response_data = JSON.parse(response.body)

        expect(response_data['type']).to eq('Activities')
        expect(response_data['features']).to eq([to_geojson(activity_a)])
      end
    end
  end
end
