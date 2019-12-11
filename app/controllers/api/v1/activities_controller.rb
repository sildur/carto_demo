# frozen_string_literal: true

class Api::V1::ActivitiesController < ApplicationController
  before_action :verify_arguments, only: [:recommended]

  def index
    conditions = {}
    conditions[:category] = params[:category] if params[:category]
    if params[:latitude] && params[:longitude]
      conditions[:latitude] = params[:latitude]
      conditions[:longitude] = params[:longitude]
    end
    results = Activity.where(conditions)
    render json: Activity.as_geojson(results), status: 200
  end

  def recommended
    results = Activity.recommended(
      category: params[:category],
      start_at: params[:start_at],
      end_at: params[:end_at], weekday: params[:weekday]
    )

    render json: Activity.as_geojson(results), status: 200
  end

  private

  def verify_arguments
    errors = []
    required_parameters = %i[category start_at end_at]

    required_parameters.each do |required_parameter|
      if params[required_parameter].blank?
        errors << "#{required_parameter} is required"
      end
    end

    time_parameters = %i[start_at end_at]
    valid_time_pattern = /([01]?[0-9]|2[0-3]):[0-5][0-9]/
    time_parameters.each do |time_parameter|
      if params[time_parameter].present? &&
         !valid_time_pattern.match?(params[time_parameter])
        errors << "#{time_parameter} has an invalid format"
      end
    end

    if errors.present?
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end
end
