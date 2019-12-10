# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :activities, only: [:index] do
        collection do
          get :recommended
        end
      end
    end
  end
end
