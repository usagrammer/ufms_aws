Rails.application.routes.draw do
  root to: "items#index"

  devise_for :users, controllers: {
                       registrations: "users/registrations",
                       sessions: "users/sessions",
                       omniauth_callbacks:  "users/omniauth_callbacks"
                     }

  devise_scope :user do
    ## ↓登録方法の選択ページ
    get "users/select_registration", to: 'users/registrations#select', as: :select_registration
    ## ↓電話番号認証ページ
    get "users/confirm_phone", to: 'users/registrations#confirm_phone', as: :confirm_phone
    ## ↓addressの登録ページ
    get "users/new_address", to: 'users/registrations#new_address', as: :new_regist_address
    ## ↓addressのcreate
    post "users/new_address", to: 'users/registrations#create_address', as: :regist_address
    ## ↓cardの登録ページ
    get "users/new_payment", to: 'users/registrations#new_payment', as: :new_regist_payment
    ## ↓登録完了ページ
    get "users/regist_completed", to: 'users/registrations#completed', as: :regist_completed
  end

  resources :users, only: [:show] do
    collection do
      get "card"
      get "selling"
      get "selling_progress"
      get "sold"
      get "bought_progress"
      get "bought_past"
    end
  end

  resources :items  do
    member do
      get "purchase_confirmation"
      post "purchase"
    end
    collection do
      get "search"
      get "scraping_category"
      get "scraping_autobike"
      get "scraping_car_parts"
      get "scraping_cosme"
      get "scraping_domestic_car"
      get "scraping_foods"
      get "scraping_forign_car"
      get "scraping_game"
      get "scraping_instrument"
      get "scraping_interior"
      get "scraping_kids"
      get "scraping_kitchen"
      get "scraping_ladies"
      get "scraping_mens"
      get "scraping_phone"
      get "scraping_sports"
      get "scraping_watch"
    end
  end
  resources :categories, only: [:index, :show]
  resource :cards, only: [:new, :create, :show, :update, :destroy]

  namespace :api do
    resources :items, only: [:create, :update], defaults: { format: 'json' }
    resources :cards, only: [:create,:destroy,:update], defaults: { format: 'json' }
    resources :categories, only: [:index], defaults: { format: 'json' } do
      collection do
        get "get_options"
      end
    end
    resources :brand_names, only: [:index], defaults: { format: 'json' }
    resources :size_groups, only: [:index], defaults: { format: 'json' }
  end
                     # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
