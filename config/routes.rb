Rails.application.routes.draw do

  # TODO - Delete this
  post "tmp/create_iteration" => "tmp#create_iteration", as: :tmp_create_iteration

  namespace :api do
    scope :v1 do
      resources :solutions, only: [:update] do
        collection do
          get :latest
        end
      end
    end
  end

  namespace :admin do
    resource :dashboard, only: [:show], controller: "dashboard"
  end

  namespace :mentor do
    resource :dashboard, only: [:show], controller: "dashboard"
    resources :solutions, only: [:show]
    resources :discussion_posts, only: [:create]
  end

  devise_for :users, controllers: {
    registrations: 'registrations',
    omniauth_callbacks: "omniauth_callbacks"
  }

  resources :profiles, only: [:index, :show]
  resources :tracks, only: [:index, :show] do
    resources :exercises, only: [:index, :show] do
      resources :solutions, only: [:index, :show]
    end
    resources :maintainers, only: [:index]
    resources :mentors, only: [:index]
  end

  namespace :my do
    resource :dashboard, only: [:show], controller: "dashboard"

    resources :tracks, only: [:index, :show] do
      resources :side_exercises, only: [:index]
    end

    resources :user_tracks, only: [:create]
    resources :solutions, only: [:show, :create] do
      member do
        get :confirm_unapproved_completion
        patch :complete
        get :reflection
        patch :reflect
      end
    end

    resources :discussion_posts, only: [:create]
    resources :notifications, only: [:index]
    resource :profile, controller: "profile"

    resource :settings do
      patch :update_user_tracks
      resource :communication_preferences, only: [:edit, :update]
    end

  end

  post "markdown/parse" => "markdown#parse"

  %w{
  donate
  }.each do |page|
    get page => "pages##{page}", as: "#{page}_page"
  end
  root to: "pages#index"
end
